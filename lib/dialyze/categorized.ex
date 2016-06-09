defmodule Dialyze.Formatter.Categorized do
  def print_warnings(warnings) do
    warnings
    |> Enum.each(&format_warning/1)
    :ok
  end

  defp format_warning(warning) do
    IO.inspect(warning)
  end
end
