defmodule Scriptengine.Utils do
  @moduledoc """
  Utilities for data exchange between Lua and Elixir
  """

  @doc """
  Converts a Lua table datatypes to an Elixir ready map value.

  Returns the converted value.

  ## Examples

      iex> to_elixir(1)
      1

      iex> to_elixir("foo")
      "foo"

      iex> to_elixir([{"fizz", "buzz"}])
      %{"fizz" => "buzz"}

      iex> to_elixir(%{"unexpected" => "value"})
      ** (ArgumentError) %{"unexpected" => "value"} cannot be converted to Elixir
  """

  def to_elixir(value) when is_binary(value), do: value
  def to_elixir(value) when is_number(value), do: value
  def to_elixir(true), do: true
  def to_elixir(false), do: false
  def to_elixir(nil), do: nil
  def to_elixir(value) when is_map(value), do: value

  def to_elixir([{key, _} | _] = value) when is_binary(key),
    do:
      value
      |> Enum.map(fn {key, value} -> {key, to_elixir(value)} end)
      |> Map.new()

  def to_elixir([{key, value} | tail]) when is_number(key),
    do: [to_elixir(value) | to_elixir(tail)]

  def to_elixir([]), do: []

  def to_elixir(value) do
    raise ArgumentError, message: "#{inspect(value)} cannot be converted to Elixir"
  end
end
