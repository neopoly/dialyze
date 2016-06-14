defmodule Mix.Tasks.DialyzeMock do
  @shortdoc "Analyses the current Mix project using success typing"

  use Mix.Task

  def run([]) do
    print_intro
    [
      "\n",
      [:yellow, "--- Broken contracts ------------------------------------------", :reset, "\n"],
      "\n",
      ["* The call 'Elixir.Timex.Timezone':get(num@1::integer(),for@1::any()) breaks the contract ('Elixir.String':t(),'Elixir.Timex.Date':datetime() | #{} | 'nil') -> #{} | {'error','Elixir.String':t()}", :reset, "\n"],
      [:faint, "  lib/timezone/timezone.ex:78", :reset, "\n"],
      ["* The call 'Elixir.Timex.Timezone':get(integer(),for@1::any()) breaks the contract ('Elixir.String':t(),'Elixir.Timex.Date':datetime() | #{} | 'nil') -> #{} | {'error','Elixir.String':t()}", :reset, "\n"],
      [:faint, "  lib/timezone/timezone.ex:84", :reset, "\n"],
    ]
    |> puts

    [
      [:red, "--- Impossible matches -------------------------------------------", :reset, "\n"],
      "\n",
      ["* The pattern ", :cyan, "<_date@1, _, _error@1 = {'error', _}>", :reset, " can never match the type ", :cyan, "<#{},_,bitstring()>", :reset, "\n"],
      [:faint, "  lib/format/datetime/formatters/default.ex:154", :reset, "\n"],
      ["* The pattern ", :cyan, "_err@1 = {'error', _}", :reset, " can never match the type ", :cyan, "binary()", :reset, "\n"],
      [:faint, "  lib/format/datetime/formatters/default.ex:160", :reset, "\n"],
      ["* The pattern ", :cyan, "{'error', _m@1}", :reset, " can never match the type ", :cyan, "{'ok',_}", :reset, "\n"],
      [:faint, "  lib/timezone/timezone_local.ex:174", :reset, "\n"],
    ]
    |> puts

    Mix.raise "Dialyzer reported 56 warnings"
  end

  def run(_non_empty_args) do
    print_intro
    [
      [:red, "--- Impossible match ---------------------------------------------", :reset, "\n"],
      "\n",
      "The pattern in line 174 can never match the type {'ok',_}.", "\n",
      "\n",
      [:faint, "lib/timezone/timezone_local.ex:174", :reset, "\n"],
      [:faint, "172|    ", :cyan, "case etctz |> parse_tzfile(date) do", :reset, "\n"],
      [:faint, "173|    ", :cyan, "   {:ok, tz}   -> {:ok, tz}", :reset, "\n"],
      [:bright, "174|>   ", :cyan, "   ", :bright, "{:error, m}", :reset, :cyan, " -> raise m", :reset, "\n"],
      [:faint, "175|    ", :cyan, " end", :reset, "\n"],
      "\n",
      "The pattern `{:error, m}` should never match since the expected return", "\n",
      "type from `&parse_tzfile/2` is `{'ok',_}`.", "\n",

    ]
    |> puts
  end

  defp print_intro do
    """
Finding applications for analysis
Finding suitable PLTs
Looking up modules in dialyze_erlang-18.1_elixir-1.2.1_deps-dev.plt
Finding applications for dialyze_erlang-18.1_elixir-1.2.1_deps-dev.plt
Finding modules for dialyze_erlang-18.1_elixir-1.2.1_deps-dev.plt
Checking 380 modules in dialyze_erlang-18.1_elixir-1.2.1_deps-dev.plt
Finding modules for analysis
Analysing 32 modules with dialyze_erlang-18.1_elixir-1.2.1_deps-dev.plt
"""
    |> IO.puts
  end

  defp puts(list) do
    list
    |> List.wrap
    |> List.flatten
    |> IO.ANSI.format
    |> IO.puts
  end
end
