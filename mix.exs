defmodule ExAws.SigV4a.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/mixi-m/ex_aws_sigv4a"

  def project do
    [
      app: :ex_aws_sigv4a,
      version: @version,
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      docs: docs(),
      name: "ExAws.SigV4a",
      source_url: @source_url
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:aws_signature, "~> 0.4.2"},
      {:ex_aws, "~> 2.0"},
      {:jason, "~> 1.3"},
      {:mox, "~> 1.0", only: :test},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false}
    ]
  end

  defp description do
    """
    AWS Signature Version 4A (SigV4a) support for ExAws.
    Enables signing requests across multiple AWS regions for services like S3 multi-region access points.
    """
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md", "CHANGELOG.md"],
      source_ref: "v#{@version}",
      source_url: @source_url
    ]
  end
end
