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
    table = :ets.new(:scriptengine_state, [:set, :private])
    {:ok, %{table: table}, {:continue, :set_default}}
  end

  @impl true
  def handle_continue(:set_default, state) do
    :ets.insert(
      state.table,
      {:default,
       Lua.new(sandboxed: @default_sandbox)
       |> Lua.load_api(Scriptengine.Extensions.Table)
       |> Lua.load_api(Scriptengine.Extensions.Time)
       |> Lua.load_api(Scriptengine.Extensions.Utils)}
    )

    {:noreply, state}
  end

  @doc """
  Returns the current state of the Lua engine.
  """
  @spec get_state() :: Lua.t()
  def get_state() do
    GenServer.call(__MODULE__, :get_state)
  end

  @spec get_state(modules :: [module()]) :: Lua.t()
  def get_state(modules) when is_list(modules) do
    GenServer.call(__MODULE__, {:get_state, modules})
  end

  @doc """
  Returns the used Lua sandboxing configuration.
  """
  @spec sandbox() :: String.t()
  def sandbox(), do: Enum.map_join(@default_sandbox, "\n", &Enum.join(&1, "."))

  # Callbacks
  @impl GenServer
  def handle_call(:get_state, _from, state) do
    [default: lua] = :ets.lookup(state.table, :default)
    {:reply, lua, state}
  end

  @impl GenServer
  def handle_call({:get_state, modules}, _from, state) do
    key = :erlang.term_to_binary(modules)

    case :ets.lookup(state.table, key) do
      [] ->
        [default: default] = :ets.lookup(state.table, :default)
        cached = bind_modules(default, modules)
        :ets.insert(state.table, {key, cached})
        {:reply, cached, state}

      [{^key, cached}] ->
        {:reply, cached, state}
    end
  end

  defp bind_modules(state, modules) do
    Enum.reduce(modules, state, fn module, acc -> Lua.load_api(acc, module) end)
  end
end
