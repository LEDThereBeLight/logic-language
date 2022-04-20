defmodule Parser do
  import NimbleParsec

  lparen = string("(")
  rparen = string(")")
  comma = string(",")
  spaces = ascii_string([?\s], min: 1)
  eol = choice([string("\r\n"), string("\n")])
  upper = ascii_string([?A..?Z], 1)
  lower_alnum = ascii_string([?a..?z, ?0..?9], 1)
  input_command = string("INPUT")
  query_command = string("QUERY")

  comma_space =
    ignore(comma)
    |> ignore(spaces)

  term_helper = fn start, the_tag ->
    start
    |> concat(ascii_string([?A..?Z, ?a..?z, ?_, ?0..?9], min: 0))
    |> wrap
    |> map({Enum, :join, [""]})
    |> unwrap_and_tag(the_tag)
  end

  variable = term_helper.(upper, :var)
  literal = term_helper.(lower_alnum, :lit)
  term = choice([variable, literal])

  statement = term_helper.(lower_alnum, :pred)

  arguments = fn to_find ->
    ignore(lparen)
    |> concat(to_find)
    |> repeat(concat(comma_space, to_find))
    |> ignore(rparen)
    |> ignore(eol)
    |> tag(:args)
  end

  clause_helper = fn cmd, to_find, the_tag ->
    ignore(cmd)
    |> ignore(spaces)
    |> concat(statement)
    |> ignore(spaces)
    |> concat(arguments.(to_find))
    |> tag(the_tag)
  end

  fact = clause_helper.(input_command, literal, :fact)
  query = clause_helper.(query_command, term, :query)
  clause = choice([fact, query])

  defparsec(:file, clause |> repeat)
end
