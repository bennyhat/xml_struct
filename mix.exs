defmodule XmlStruct.MixProject do
  use Mix.Project

  def project do
    [
      app: :xml_struct,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps()
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
end
