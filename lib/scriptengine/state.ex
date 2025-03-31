defmodule Scriptengine.State do
  use GenServer

  @default_sandbox [
    [:io],
    [:file],
    [:os, :execute],
    [:os, :exit],
    [:os, :getenv],
    [:os, :remove],
    [:os, :rename],
    [:os, :tmpname],
    [:package],
    [:load],
    [:loadfile],
    [:require],
    [:dofile],
    [:load],
    [:loadfile],
    [:loadstring]
  ]

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    {:ok,
     Lua.new(sandboxed: @default_sandbox)
     |> Lua.load_api(Scriptengine.Extensions.Table)
     |> Lua.load_api(Scriptengine.Extensions.Time)
     |> Lua.load_api(Scriptengine.Extensions.Utils)}
  end

  @doc """
  Returns the current state of the Lua engine.
  """
  @spec get_state() :: Lua.t()
  def get_state() do
    GenServer.call(__MODULE__, :get_state)
  end

  @doc """
  Returns the used Lua sandboxing configuration.
  """
  @spec sandbox() :: String.t()
  def sandbox(), do: Enum.map_join(@default_sandbox, "\n", &Enum.join(&1, "."))

  # Callbacks
  @impl GenServer
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end
end
