defmodule ExAws.SigV4a.Auth do
  @moduledoc """
  Generates AWS Signature Version 4A (SigV4a) authentication headers.
  """

  alias ExAws.SigV4a.RegionSet

  @doc """
  Generates SigV4a authentication headers.

  ## Parameters
  - `http_method` - HTTP method (e.g., "GET", "POST")
  - `url` - Request URL
  - `service` - AWS service name (e.g., "s3", "dynamodb")
  - `config` - ExAws configuration (including region_set)
  - `headers` - Existing headers list
  - `body` - Request body

  ## Return Values
  - `{:ok, headers}` - Signed headers list
  - `{:error, reason}` - On error
  """
  @spec headers(
          http_method :: String.t() | atom(),
          url :: String.t(),
          service :: String.t() | atom(),
          config :: map(),
          headers :: [{String.t(), String.t()}],
          body :: binary()
        ) :: {:ok, [{String.t(), String.t()}]} | {:error, term()}
  def headers(http_method, url, service, config, headers, body) do
    with {:ok, config} <- validate_config(config) do
      generate_signed_headers(http_method, url, service, config, headers, body)
    end
  end

  defp validate_config(config) do
    required_keys = [:access_key_id, :secret_access_key]

    missing_keys =
      Enum.filter(required_keys, fn key ->
        is_nil(Map.get(config, key))
      end)

    case missing_keys do
      [] -> {:ok, config}
      keys -> {:error, {:missing_config, keys}}
    end
  end

  defp generate_signed_headers(http_method, url, service, config, headers, body) do
    regions = RegionSet.resolve_region_set(config)
    method = http_method |> to_string() |> String.upcase()
    service_name = to_string(service)
    session_token = Map.get(config, :security_token, "")
    erlang_headers = convert_headers_to_erlang(headers)
    body_binary = to_binary(body)
    options = build_options(service_name)

    case :aws_signature.sign_v4a(
           config.access_key_id,
           config.secret_access_key,
           session_token,
           regions,
           service_name,
           method,
           url,
           erlang_headers,
           body_binary,
           options
         ) do
      {:ok, signed_headers} ->
        {:ok, convert_headers_to_elixir(signed_headers)}

      {:error, reason} ->
        {:error, {:sigv4a_error, reason}}
    end
  end

  defp convert_headers_to_erlang(headers) when is_map(headers) do
    headers |> Map.to_list() |> convert_headers_to_erlang()
  end

  defp convert_headers_to_erlang(headers) when is_list(headers) do
    Enum.map(headers, fn
      {key, value} when is_binary(key) and is_binary(value) ->
        {key, value}

      {key, value} ->
        {to_string(key), to_string(value)}
    end)
  end

  defp convert_headers_to_elixir(headers) do
    Enum.map(headers, fn {key, value} ->
      {to_string(key), to_string(value)}
    end)
  end

  defp to_binary(data) when is_binary(data), do: data
  defp to_binary(data) when is_list(data), do: IO.iodata_to_binary(data)
  defp to_binary(data), do: to_string(data)

  defp build_options("s3") do
    %{
      add_payload_hash_header: true,
      disable_implicit_payload_hashing: false
    }
  end

  defp build_options(_service_name) do
    %{
      add_payload_hash_header: false,
      disable_implicit_payload_hashing: false
    }
  end
end
