defmodule Unify do
  # https://cgi.luddy.indiana.edu/~c311/lib/exe/fetch.php?media=microkanren.pdf

  @type lvar :: {:var, String.t()}
  @type lit :: {:lit, String.t()}

  @type substitution :: %{lvar => lterm}
  @type state :: {substitution, lvar}
  @type lterm :: lvar | lit | [lterm]

  ###
  # Client
  def unify_all(facts, terms), do: Enum.map(facts, &unify(terms, &1, %{}))

  @spec unify(lterm, lterm, substitution) :: substitution | false
  def unify(left, right, sub), do: unify_go(dereference(left, sub), dereference(right, sub), sub)

  ###
  # Helpers
  defp unify_go([left | lefts], [right | rights], sub) do
    case unify(left, right, sub) do
      false -> false
      sub1 -> unify(lefts, rights, sub1)
    end
  end

  defp unify_go([_ | _], _, _), do: false
  defp unify_go(_, [_ | _], _), do: false
  defp unify_go(left, right, sub) when left == right, do: sub
  defp unify_go({:var, _} = left, right, sub), do: extend_sub(left, right, sub)
  defp unify_go(left, {:var, _} = right, sub), do: extend_sub(right, left, sub)
  defp unify_go(_, _, _), do: false

  defp extend_sub(left, right, sub), do: Map.put(sub, left, right)

  @spec dereference(lterm, substitution) :: lterm
  defp dereference({:var, _} = term, sub) do
    case get_next_reference(sub, term) do
      nil -> term
      next_step -> dereference(next_step, sub)
    end
  end

  defp dereference(term, _), do: term

  defp get_next_reference(sub, term), do: Map.get(sub, term)
end
