defmodule XmlStruct.MixProject do
  use Mix.Project

  def project do
    [
      app: :xml_struct,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      test_paths: test_paths(Mix.env())
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:accessible, "~> 0.2.1"},
      {:sweet_xml, "~> 0.6"},
      {:typed_struct, "~> 0.1.4"},
      {:recase, "~> 0.5"},
      {:inflectorex, "~> 0.1.2"},
      {:checkov, "~> 1.0", only: :test},
      {:faker, "~> 0.13", only: :test}
    ]
  end

  defp elixirc_paths(env) when env in [:test, :integration], do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp test_paths(_), do: ["test/unit"]
end
