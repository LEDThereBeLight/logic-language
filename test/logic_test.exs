defmodule LogicTest do
  use ExUnit.Case, async: true

  @input_file_directory "examples/in"
  @output_file_directory "examples/out"

  test "eval" do
    # Files must be named in{num}.txt or out{num}.txt. Ex. in1.txt

    callback = fn file_name, actual_output ->
      target_output = read_target_output(file_name)

      log_results(actual_output, target_output)
      compare_results(actual_output, target_output)
    end

    Main.run_all(@input_file_directory, callback)
  end

  def read_target_output(file_name) do
    file_number = List.last(String.split(file_name, "in"))

    File.read!(Path.join([Path.expand("."), @output_file_directory <> "/out" <> file_number]))
    |> String.trim()
  end

  def log_results(result, target) do
    IO.inspect(result, label: "Evalua output")
    IO.inspect(target, label: "Target output")
  end

  def compare_results(result, target) do
    for line <- String.split(target, "\n") do
      # The results might be out of order, so I'm just checking that
      # all the lines are present. Not the greatest, but does fine
      # for the example tests.
      assert result =~ line
    end
  end
end
