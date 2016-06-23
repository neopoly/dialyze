defmodule Mix.Tasks.DialyzeMock do
  def run(args) do
    Dialyze.Mock.warnings |> Dialyze.Formatter.Categorized.print_warnings
  end
end
