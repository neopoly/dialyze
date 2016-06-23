defmodule Dialyze.Formatter.Categorized do
  defmodule Warning do
    defstruct [:category, :filename, :line, :metadata, :original]
  end

  @categories [
    warn_return_no_exit:  {:normal,   "Return no exit?"},
    warn_behaviour:       {:cyan,     "Behaviour"},
    warn_contract_range:  {:yellow,   "Contract Range"},
    warn_contract_types:  {:blue,     "Contract Types"},
    warn_failing_call:    {:magenta,  "Failing call"},
    warn_matching:        {:red,      "Impossible match"},
  ]

  def print_warnings(warnings) do
    grouped =
      warnings
      |> Enum.map(&cast_warning/1)
      |> Enum.group_by(&(&1.category))

    @categories
    |> Keyword.keys
    |> Enum.each(&print_category(@categories[&1], grouped[&1]))

    :ok
  end

  defp cast_warning({category, {filename, line}, metadata} = warning) do
    %Warning{
      category: category,
      filename: filename |> to_string,
      line: line,
      metadata: metadata,
      original: warning
    }
  end

  defp print_category(_category, nil) do
    nil
  end

  defp print_category({color, title}, warnings) do
    puts
    puts [color, "--- #{title} ---"]
    puts

    warnings
    |> Enum.take(5)
    |> Enum.each(&format_warning/1)

    puts
  end

  defp format_warning(%Warning{
                        filename: filename,
                        line: line,
                        metadata: _metadata,
                        category: _category} = warning) do
    puts "* #{format_details warning}"
    puts [:faint, "  #{filename}:#{line}"]
  end

  defp format_details(%Warning{
                        category: :warn_matching,
                        metadata: {:pattern_match, ['pattern ' ++ lhs, rhs]}
                      }) do

    "The pattern #{code lhs} can never match the type #{code rhs}"
  end

  defp format_details(%Warning{
                        category: :warn_matching,
                        metadata: {
                          :pattern_match_cov, ['variable ' ++ lhs, rhs]}
                      }) do

    "The variable #{code lhs} can never match since previous clauses " <>
      "completely covered the type #{code rhs}"
  end


  # Fallback to original implementation
  defp format_details(%Warning{original: warning, metadata: metadata}) do
    original_warning =
      warning
      |> :dialyzer.format_warning(:fullpath)
      |> IO.chardata_to_string()
      |> String.replace(~r{^.*?(\S+)\s}, "")
      |> String.strip

    original_metadata = inspect(metadata) |> code

    "#{original_warning}\n  #{original_metadata}"
  end

  defp puts, do: IO.puts ""
  defp puts(string) when is_binary(string), do: IO.puts string
  defp puts(args) when is_list(args), do: IO.ANSI.format(args) |> IO.puts

  defp colorize(color, args), do: IO.ANSI.format([color, to_string args])

  defp code(value) do
    colorize :cyan, atomize value
  end

  defp atomize(string) when is_binary(string), do: string

  defp atomize('_' ++ _rest = charlist) when is_list(charlist) do
    charlist
  end

  defp atomize(charlist) when is_list(charlist) do
    ":#{charlist |> IO.chardata_to_string |> String.replace("'", "")}"
  end
end
