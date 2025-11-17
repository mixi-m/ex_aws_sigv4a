defmodule ExAws.SigV4a do
  @moduledoc """
  Adds AWS Signature Version 4A (SigV4a) support to ExAws.

  SigV4a is an extension of SigV4 that can sign requests spanning multiple AWS regions.
  It is primarily used for S3 multi-region access points and other global AWS services.

  ## Examples

      # S3 multi-region access point
      ExAws.S3.list_objects("my-multi-region-access-point")
      |> ExAws.SigV4a.request(region_set: "*")

      # Explicitly specify access key
      config = [
        region_set: ["us-east-1", "us-west-2"],
        access_key_id: "AKIAIOSFODNN7EXAMPLE",
        secret_access_key: "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
      ]

      ExAws.S3.get_object("bucket", "key")
      |> ExAws.SigV4a.request(config)
  """

  alias ExAws.SigV4a.Auth

  @doc """
  Executes an ExAws Operation using SigV4a authentication.

  ## Parameters
  - `operation` - ExAws Operation struct
  - `config_overrides` - Configuration overrides (keyword list or map)

  ## Configuration Options
  - `:region_set` - Region set (string, list, or "*")
  - Other standard ExAws configuration options

  ## Return Values
  - `{:ok, response}` - On success
  - `{:error, reason}` - On error
  """
  @spec request(ExAws.Operation.t(), Keyword.t() | map()) ::
          {:ok, term()} | {:error, term()}
  def request(operation, config_overrides \\ []) do
    config = build_config(operation, config_overrides)
    url = ExAws.Request.Url.build(operation, config)
    http_method = get_http_method(operation)
    headers = get_headers(operation)
    body = get_body(operation)
    service = get_service(operation)

    case Auth.headers(http_method, url, service, config, headers, body) do
      {:ok, signed_headers} ->
        ExAws.Request.request(http_method, url, body, signed_headers, config, service)

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Generates a presigned URL using SigV4a authentication.

  Currently not implemented.
  """
  @spec presigned_url(ExAws.Operation.t(), Keyword.t(), Keyword.t()) ::
          {:ok, String.t()} | {:error, term()}
  def presigned_url(_operation, _config_overrides \\ [], _options \\ []) do
    {:error, :not_implemented}
  end

  defp build_config(operation, config_overrides) do
    service = get_service(operation)
    base_config = ExAws.Config.new(service, config_overrides)
    overrides = Map.new(config_overrides)

    base_config
    |> Map.merge(overrides)
    |> resolve_credentials()
    |> Map.put(:disable_headers_signature, true)
  end

  defp resolve_credentials(config) do
    config
    |> Map.update(:access_key_id, nil, &resolve_runtime_value(&1, config))
    |> Map.update(:secret_access_key, nil, &resolve_runtime_value(&1, config))
    |> Map.update(:security_token, nil, &resolve_runtime_value(&1, config))
  end

  defp resolve_runtime_value(value, config) when is_list(value) or is_tuple(value) do
    ExAws.Config.retrieve_runtime_value(value, config)
  end

  defp resolve_runtime_value(value, _config), do: value

  defp get_http_method(%{http_method: method}), do: method
  defp get_http_method(_), do: :get

  defp get_headers(%{headers: headers}) when is_map(headers), do: Map.to_list(headers)
  defp get_headers(%{headers: headers}) when is_list(headers), do: headers
  defp get_headers(_), do: []

  defp get_body(%{body: body}), do: body
  defp get_body(%{data: data}), do: Jason.encode!(data)
  defp get_body(_), do: ""

  defp get_service(%{service: service}), do: service

  defp get_service(%module{}) do
    module
    |> Module.split()
    |> List.last()
    |> String.downcase()
    |> String.to_atom()
  end
end
