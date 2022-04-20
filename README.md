# Setup

* Install elixir, version 1.13
* run `mix deps.get`
* run `mix test`

# How to change the examples

The example input files are under `/examples/in` and the expected outputs are under `/examples/out`. The test basically just matches the file numbers in `in` and `out` and compares the results. However, the results might be out of order, so it just checks if all of the lines are present in both files. This isn't exact, but I was running out of time and wanted to get something together.

# App explanation

`main.ex` reads a file, parses it, and sends a command along with a line of the AST to `db.ex`. `db.ex` is our in-memory db and can either add a fact or query a fact.

Adding a fact creates an index for each distinct predicate and associates each term given as an argument with every other term.

Querying a fact checks the db for relevant relations by trying to narrow relations down by predicate name and the literal terms given as arguments.

Once it has a list of facts, it unifies each variable with all possible literals satisfying the constraints created by those facts in the db.

After unification, it reifies the results to turn them into strings for writing to STDIO.
