defmodule ExAws.SigV4aTest do
  use ExUnit.Case, async: false

  describe "presigned_url/3" do
    test "returns error as it is not yet implemented" do
      operation = %ExAws.Operation.S3{
        http_method: :get,
        bucket: "test-bucket",
        path: "/test.txt",
        headers: [],
        body: "",
        service: :s3
      }

      assert {:error, :not_implemented} = ExAws.SigV4a.presigned_url(operation)
    end
  end

  describe "request/2 helper function tests" do
    @tag :skip
    test "disable_headers_signature is configured" do
      operation = %ExAws.Operation.S3{
        http_method: :get,
        bucket: "test-bucket",
        path: "/test.txt",
        headers: [],
        body: "",
        service: :s3
      }

      assert {:error, {:missing_config, _keys}} =
               ExAws.SigV4a.request(operation, region_set: "*")
    end

    @tag :skip
    test "configuration overrides are applied" do
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
        secret_access_key: "test_secret"
      ]

      result = ExAws.SigV4a.request(operation, config_overrides)

      case result do
        {:error, {:missing_config, _}} -> flunk("Configuration was not applied")
        _ -> :ok
      end
    end
  end
end
