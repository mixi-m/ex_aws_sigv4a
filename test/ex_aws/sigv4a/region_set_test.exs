defmodule ExAws.SigV4a.RegionSetTest do
  use ExUnit.Case, async: true
  alias ExAws.SigV4a.RegionSet

  doctest ExAws.SigV4a.RegionSet

  describe "resolve_region_set/1" do
    test "converts string region_set to list" do
      config = %{region_set: "*"}
      assert RegionSet.resolve_region_set(config) == ["*"]
    end

    test "uses list region_set as-is" do
      config = %{region_set: ["us-east-1", "us-west-2"]}
      assert RegionSet.resolve_region_set(config) == ["us-east-1", "us-west-2"]
    end

    test "uses default value (*) when region_set is absent" do
      config = %{}
      assert RegionSet.resolve_region_set(config) == ["*"]
    end

    test "converts atom list from region_set" do
      config = %{region_set: [:"us-east-1", :"us-west-2"]}
      assert RegionSet.resolve_region_set(config) == ["us-east-1", "us-west-2"]
    end
  end

  describe "to_scope_string/1" do
    test "converts single region" do
      assert RegionSet.to_scope_string(["us-east-1"]) == "us-east-1"
    end

    test "converts multiple regions to comma-separated format" do
      result = RegionSet.to_scope_string(["us-east-1", "us-west-2", "eu-west-1"])
      assert result == "us-east-1,us-west-2,eu-west-1"
    end

    test "converts wildcard" do
      assert RegionSet.to_scope_string(["*"]) == "*"
    end

    test "converts empty list" do
      assert RegionSet.to_scope_string([]) == ""
    end
  end
end
