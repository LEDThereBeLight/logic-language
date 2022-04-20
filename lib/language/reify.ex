defmodule Reify do
  def reify(unifications) when is_list(unifications) do
    if Enum.all?(unifications) do
      reify_success(unifications)
    else
      reify_failure()
    end
  end

  def reify(unification), do: reify([unification])

  def reify_failure(), do: "false"

  defp reify_success(unifications) when is_list(unifications) do
    unifications
    |> Enum.map(&reify_success/1)
    |> finalize_reification()
  end

  defp reify_success(unification) do
    unification
    |> Map.to_list()
    |> Enum.map(&reify_pair/1)
    |> Enum.join(", ")
  end

  defp reify_pair({{:var, var}, {:lit, lit}}), do: var <> ": " <> lit
  defp reify_pair({{:var, _var1}, {:var, _var2}}), do: "true"
  defp finalize_reification([""]), do: "true"
  defp finalize_reification(reificiations), do: Enum.join(reificiations, "\n")
end
