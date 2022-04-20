defmodule Main do
  ###
  # API
  def run_all(directory_path, cb) do
    for file_name <- get_files(Path.join(Path.expand("."), directory_path)) do
      cb.(file_name, run(directory_path <> "/" <> file_name))
    end
  end

  def run(file_path) do
    {:ok, db} = Db.start_link()

    result =
      File.read!(file_path)
      |> Parser.file()
      |> then(
        &case &1 do
          {:ok, lines, _, _, _, _} ->
            process_and_join_lines(db, lines)

          {:error, reason, _, _, _, _} ->
            reason
        end
      )

    Db.close(db)

    result
  end

  ###
  # Helpers
  defp get_files(path) do
    File.ls!(path)
  end

  defp process_and_join_lines(db, lines) do
    Enum.reduce(lines, "", fn line, result ->
      case handle_line(db, line) do
        :ok -> result
        new_results -> result <> "---\n" <> new_results <> "\n"
      end
    end)
    |> String.trim()
  end

  defp handle_line(db, {:fact, [pred: pred, args: args]}), do: Db.add_fact(db, pred, args)
  defp handle_line(db, {:query, [pred: pred, args: args]}), do: Db.query(db, pred, args)
end
