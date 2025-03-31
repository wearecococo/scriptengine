defmodule Scriptengine do
  import Scriptengine.Utils

  @moduledoc """
  Documentation for `Scriptengine`.

  Scriptengine is a Lua script engine for Elixir. It allows you to run Lua scripts
  within your Elixir application. It provides a simple API to execute Lua scripts
  and exchange data between Lua and Elixir.
  ## Examples

      iex> Scriptengine.run_chunk("return 1 + 1")
      2

      iex> Scriptengine.run_chunk("return {foo = 'bar', baz = 'qux'}")
      %{"foo" => "bar", "baz" => "qux"}

      iex> Scriptengine.run_chunk("return {1, 2, 3}")
      [1, 2, 3]

      iex> Scriptengine.run_chunk("return {1, context.params.foo, 3}", %{foo: "bar"})
      [1, "bar", 3]
  """

  @doc """
  Accepts a chunk of Lua code and executes it.
  """
  def run_chunk(script, context \\ %{}) do
    Scriptengine.State.get_state()
    |> Lua.set!([:context, :params], context)
    |> Lua.eval!(script)
    |> case do
      {[], _} -> nil
      {[res], _} -> to_elixir(res)
      {nil, _} -> nil
      {res, _} -> Enum.map(res, &to_elixir/1)
    end
  end

  @doc """
  Accepts a lua script that has a `main` function
  and executes that function with the provided params.
  """
  def run_main(script, context \\ %{}) do
    with {_, state} <-
           Scriptengine.State.get_state()
           |> Lua.eval!(script) do
      state
      |> Lua.call_function!("main", [context])
      |> case do
        {[], _} -> {:ok, nil}
        {[res], _} -> {:ok, to_elixir(res)}
        {nil, _} -> {:ok, nil}
        {res, _} -> {:ok, Enum.map(res, &to_elixir/1)}
      end
    end
  rescue
    error in Lua.RuntimeException ->
      {:error, error.message}
  end

  @doc """
  Compiles a script into a Lua Chunk
  """
  def compile(script), do: Lua.parse_chunk(script)

  @doc """
  Validates a script is valid Lua
  """
  def validate(script) do
    case compile(script) do
      {:ok, _} -> :ok
      err -> err
    end
  end
end
