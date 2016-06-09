defmodule Dialyze.Formatter.Categorized do
  defmodule Warning do
    defstruct [:category, :filename, :line, :metadata]
  end

  def print_warnings(warnings) do
    warnings
    |> Enum.map(&cast_warning/1)
    |> Enum.sort_by(&(&1.category))
    # |> Enum.group_by
    # |> Enum.take 5
    |> Enum.each(&format_warning/1)
    :ok
  end

  defp cast_warning({category, {filename, line}, metadata}) do
    %Warning{
      category: category,
      filename: filename |> to_string,
      line: line,
      metadata: metadata
    }
  end

  defp format_warning(warning) do
    IO.inspect(warning)
  end
end
