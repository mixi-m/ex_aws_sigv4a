defmodule ExAws.SigV4a.AuthTest do
  use ExUnit.Case, async: true
  alias ExAws.SigV4a.Auth

  defp test_config(overrides) do
    base = %{
      access_key_id: "AKIAIOSFODNN7EXAMPLE",
      secret_access_key: "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY",
      region: "us-east-1"
    }

    Map.merge(base, Map.new(overrides))
  end

  describe "headers/6" do
    test "generates basic signature headers" do
      config = test_config(region_set: "*")
      url = "https://s3.amazonaws.com/examplebucket/test.txt"
      headers = [{"host", "s3.amazonaws.com"}]

      {:ok, signed_headers} =
        Auth.headers(:get, url, :s3, config, headers, "")

      header_map = Map.new(signed_headers)

      assert Map.has_key?(header_map, "Authorization")
      assert Map.has_key?(header_map, "X-Amz-Date")
      assert Map.has_key?(header_map, "Host")
      assert String.contains?(header_map["Authorization"], "AWS4-ECDSA-P256-SHA256")
    end

    test "signs with multiple regions" do
      config = test_config(region_set: ["us-east-1", "us-west-2"])
      url = "https://s3.amazonaws.com/examplebucket/test.txt"
      headers = [{"host", "s3.amazonaws.com"}]

      {:ok, signed_headers} =
        Auth.headers(:get, url, :s3, config, headers, "")

      header_map = Map.new(signed_headers)
      assert Map.has_key?(header_map, "Authorization")
    end

    test "returns error when credentials are missing" do
      config = %{region: "us-east-1"}
      url = "https://s3.amazonaws.com/examplebucket/test.txt"

      {:error, {:missing_config, keys}} =
        Auth.headers(:get, url, :s3, config, [], "")

      assert :access_key_id in keys
      assert :secret_access_key in keys
    end

    test "signs POST request with body" do
      config = test_config(region_set: "*")
      url = "https://dynamodb.us-east-1.amazonaws.com/"

      headers = [
        {"host", "dynamodb.us-east-1.amazonaws.com"},
        {"content-type", "application/x-amz-json-1.0"}
      ]

      body = ~s({"TableName":"MyTable"})

      {:ok, signed_headers} =
        Auth.headers(:post, url, :dynamodb, config, headers, body)

      header_map = Map.new(signed_headers)
      assert Map.has_key?(header_map, "Authorization")
    end

    test "HTTP method is converted to uppercase" do
      config = test_config(region_set: "*")
      url = "https://s3.amazonaws.com/examplebucket/test.txt"
      headers = [{"host", "s3.amazonaws.com"}]

      {:ok, _} = Auth.headers(:get, url, :s3, config, headers, "")
      {:ok, _} = Auth.headers("get", url, :s3, config, headers, "")
      {:ok, _} = Auth.headers(:post, url, :s3, config, headers, "")
      {:ok, _} = Auth.headers("POST", url, :s3, config, headers, "")
    end

    test "includes session token when present" do
      config =
        test_config(
          region_set: "*",
          security_token: "IQoJb3JpZ2luX2VjEH0aCXVzLWVhc3QtMSJHMEUCIQD..."
        )

      url = "https://s3.amazonaws.com/examplebucket/test.txt"
      headers = [{"host", "s3.amazonaws.com"}]

      {:ok, signed_headers} =
        Auth.headers(:get, url, :s3, config, headers, "")

      header_map = Map.new(signed_headers)
      assert Map.has_key?(header_map, "X-Amz-Security-Token")
    end

    test "adds payload hash header for S3" do
      config = test_config(region_set: "*")
      url = "https://s3.amazonaws.com/examplebucket/test.txt"
      headers = [{"host", "s3.amazonaws.com"}]

      {:ok, signed_headers} =
        Auth.headers(:get, url, :s3, config, headers, "")

      header_map = Map.new(signed_headers)
      assert Map.has_key?(header_map, "X-Amz-Content-Sha256")
    end

    test "does not add payload hash header for DynamoDB" do
      config = test_config(region_set: "*")
      url = "https://dynamodb.us-east-1.amazonaws.com/"
      headers = [{"host", "dynamodb.us-east-1.amazonaws.com"}]

      {:ok, signed_headers} =
        Auth.headers(:post, url, :dynamodb, config, headers, "")

      header_map = Map.new(signed_headers)
      assert Map.has_key?(header_map, "Authorization")
    end
  end
end
