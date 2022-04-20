defmodule Relation do
  use Agent

  defstruct [:facts, :index]

  ###
  # Client
  def start_link(opts \\ []) do
    Agent.start_link(
      fn -> %__MODULE__{facts: MapSet.new(), index: %{}} end,
      opts
    )
  end

  def add_fact(relation, terms) do
    Agent.update(relation, fn %__MODULE__{facts: facts, index: index} ->
      %__MODULE__{
        facts: update_facts(facts, terms),
        index: update_index(index, terms)
      }
    end)
  end

  def all_facts(relation), do: Agent.get(relation, & &1.facts)
  def index(relation), do: Agent.get(relation, & &1.index)

  @spec facts_for(Agent.agent(), [String.t()]) :: [[String.t()]]
  def facts_for(relation, terms) do
    case indexed_facts(relation, terms) do
      [] ->
        Relation.all_facts(relation)

      indexed ->
        indexed
    end
  end

  def indexed_facts(relation, terms) do
    Agent.get(relation, fn %{index: index} ->
      terms
      |> Enum.map(&Map.get(index, &1))
      |> Enum.reject(&is_nil/1)
      |> intersect_all
    end)
  end

  ###
  # Helpers
  defp update_facts(facts, terms), do: MapSet.put(facts, terms)

  defp update_index(index, terms) do
    index_updated_with_terms =
      Enum.reduce(terms, %{}, fn term, original_terms ->
        updated_terms =
          index
          |> Map.get(term, MapSet.new())
          |> MapSet.put(terms)

        Map.put(original_terms, term, updated_terms)
      end)

    Map.merge(index, index_updated_with_terms)
  end

  defp intersect_all([]), do: []

  defp intersect_all(sets) do
    sets
    |> Enum.reduce(&MapSet.intersection/2)
    |> MapSet.to_list()
  end
end
