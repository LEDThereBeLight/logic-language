defmodule Db do
  use GenServer

  ###
  # Client
  def start_link(opts \\ []), do: GenServer.start_link(__MODULE__, :ok, opts)

  def add_fact(db, relation_name, args), do: GenServer.cast(db, {:add_fact, relation_name, args})

  def query(db, relation_name, args),
    do: GenServer.call(db, {:query, relation_name, args})

  def close(db), do: GenServer.stop(db)

  ###
  # Server
  @relations %{}

  @impl true
  def init(:ok), do: {:ok, @relations}

  @impl true
  def handle_cast({:add_fact, relation_name, terms}, relations) do
    relations = put_new_relation(relations, relation_name)
    {:ok, relation} = get_relation(relations, relation_name)

    Relation.add_fact(relation, terms)

    {:noreply, relations}
  end

  @impl true
  def handle_call({:query, relation_name, terms}, _, relations) do
    case get_relation(relations, relation_name) do
      {:ok, relation} ->
        Relation.facts_for(relation, terms)
        |> Unify.unify_all(terms)
        |> Reify.reify()
        |> then(&{:reply, &1, relations})

      :error ->
        {:reply, Reify.reify_failure(), relations}
    end
  end

  ###
  # Helpers
  defp get_relation(relations, name), do: Map.fetch(relations, name)

  defp put_new_relation(relations, name) do
    if Map.has_key?(relations, name) do
      relations
    else
      {:ok, relation} = Relation.start_link()
      Map.put(relations, name, relation)
    end
  end
end
