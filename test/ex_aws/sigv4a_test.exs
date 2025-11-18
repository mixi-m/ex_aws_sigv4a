defmodule ExAws.SigV4aTest do
  use ExUnit.Case, async: false
  import Mox

  setup :verify_on_exit!

  describe "request/2 helper function tests" do
    test "disable_headers_signature is configured" do
      operation = %ExAws.Operation.S3{
        http_method: :get,
        bucket: "test-bucket",
        path: "/test.txt",
        headers: [],
        body: "",
        service: :s3
      }

      # Without access_key_id and secret_access_key, should return missing_config error
      assert {:error, {:missing_config, keys}} =
               ExAws.SigV4a.request(operation,
                 region_set: "*",
                 access_key_id: nil,
                 secret_access_key: nil
               )

      assert :access_key_id in keys
      assert :secret_access_key in keys
    end

    test "configuration overrides are applied and request is made" do
      operation = %ExAws.Operation.S3{
        http_method: :get,
        bucket: "test-bucket",
        path: "/test.txt",
        headers: [],
        body: "",
        service: :s3
      }

      config_overrides = [
        region_set: "*",
        access_key_id: "test_key",
        secret_access_key: "test_secret",
        http_client: ExAws.Request.HttpClientMock
      ]

      # Expect the HTTP client to be called
      expect(ExAws.Request.HttpClientMock, :request, fn _method, _url, _body, _headers, _opts ->
        {:ok, %{status_code: 200, body: "", headers: []}}
      end)

      result = ExAws.SigV4a.request(operation, config_overrides)

      case result do
        {:error, {:missing_config, _}} -> flunk("Configuration was not applied")
        {:ok, %{status_code: 200}} -> :ok
        other -> flunk("Unexpected result: #{inspect(other)}")
      end
    end
  end
end
