defmodule Scriptengine do
  import Scriptengine.Utils

  @moduledoc """
  Documentation for `Scriptengine`.

  Scriptengine is a Lua script engine for Elixir. It allows you to run Lua scripts
  within your Elixir application. It provides a simple API to execute Lua scripts
  and exchange data between Lua and Elixir.
  ## Examples

      iex> Scriptengine.run("return 1 + 1")
      {:ok, 2}

      iex> Scriptengine.run("return {foo = 'bar', baz = 'qux'}")
      {:ok, %{"foo" => "bar", "baz" => "qux"}}

      iex> Scriptengine.run("return {1, 2, 3}")
      {:ok, [1, 2, 3]}

      iex> Scriptengine.run("return {1, context.params.foo, 3}", context: %{foo: "bar"})
      {:ok, [1, "bar", 3]}
  """

  @doc """
  Accepts a chunk of Lua code and executes it.
  """
  def run(script, opts \\ []) do
    context = Keyword.get(opts, :context, %{})
    extra_modules = Keyword.get(opts, :extra_modules, [])
    run_in_state(build_state(extra_modules), script, context)
  end

  @doc """
  Runs a script in a given state.
  """
  def run_in_state(state, script, context \\ %{}, private \\ %{}) do
    state
    |> Lua.set!([:context, :params], context)
    |> append_private_to_state(private)
    |> Lua.eval!(script)
    |> case do
      {[], _} -> {:ok, nil}
      {[res], _} -> {:ok, to_elixir(res)}
      {nil, _} -> {:ok, nil}
      {res, _} -> {:ok, Enum.map(res, &to_elixir/1)}
    end
  rescue
    error in Lua.CompilerException ->
      {:error, error.errors}

    error in Lua.RuntimeException ->
      {:error, error.message}
  end

  @doc """
  Builds a new Lua state with the given extra modules.
  States should be reused if possible.
  """
  def build_state(extra_modules \\ []) do
    Scriptengine.State.get_state(extra_modules)
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

  # TODO: cache response
  @doc """
  Returns the documentation for the Scriptengine library.
  """
  def get_docs(extra_modules \\ []) do
    [
      Scriptengine.Extensions.Table,
      Scriptengine.Extensions.Time,
      Scriptengine.Extensions.Utils
      | extra_modules
    ]
    |> Enum.map_join("\n\n", fn module ->
      Code.fetch_docs(module)
      |> case do
        {:docs_v1, _, :elixir, _, %{"en" => doc}, _, _} -> doc
        _ -> ""
      end
    end)
  end

  # Adds private variables to the state.
  # Private variables are not exposed to the Lua script.
  defp append_private_to_state(state, private) do
    Lua.put_private!(state, [:private], private)
  end
end
