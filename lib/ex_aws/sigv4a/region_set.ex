defmodule ExAws.SigV4a.RegionSet do
  @moduledoc """
  Handles parsing and processing of region sets.
  """

  @doc """
  Resolves the region set from configuration.

  Priority:
  1. Use config[:region_set] if specified
  2. Use "*" (global) as default if neither is specified

  ## Examples

      iex> ExAws.SigV4a.RegionSet.resolve_region_set(%{region_set: "*"})
      ["*"]

      iex> ExAws.SigV4a.RegionSet.resolve_region_set(%{region_set: ["us-east-1", "us-west-2"]})
      ["us-east-1", "us-west-2"]

      iex> ExAws.SigV4a.RegionSet.resolve_region_set(%{})
      ["*"]
  """
  @spec resolve_region_set(map()) :: [binary()]
  def resolve_region_set(config) do
    case Map.get(config, :region_set) do
      nil ->
        ["*"]

      region_set when is_binary(region_set) ->
        [region_set]

      region_set when is_list(region_set) ->
        Enum.map(region_set, &to_string/1)
    end
  end

  @doc """
  Converts a region set to a string for use in Credential Scope.

  ## Examples

      iex> ExAws.SigV4a.RegionSet.to_scope_string(["*"])
      "*"

      iex> ExAws.SigV4a.RegionSet.to_scope_string(["us-east-1", "us-west-2"])
      "us-east-1,us-west-2"
  """
  @spec to_scope_string([binary()]) :: binary()
  def to_scope_string(region_set) when is_list(region_set) do
    Enum.join(region_set, ",")
  end
end
