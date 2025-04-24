defmodule ScriptengineTest do
  use ExUnit.Case
  doctest Scriptengine

  import Scriptengine, only: [run: 2, run_in_state: 3, run_in_state: 4]

  defmodule Foo do
    use Lua.API

    deflua foo() do
      ["foo"]
    end
  end

  setup do
    state = Scriptengine.State.get_state([Foo])
    %{state: state}
  end

  describe "run_in_state/3" do
    test "returns the result of the script", %{state: state} do
      res = run_in_state(state, "return 1 + 1", %{})
      assert res == {:ok, 2}
    end

    test "can access the context", %{state: state} do
      res = run_in_state(state, "return context.params.foo", %{"foo" => "bar"})
      assert res == {:ok, "bar"}
    end

    test "returns an error if code is not valid", %{state: state} do
      res = run_in_state(state, "function not_main()", %{})
      assert res == {:error, ["Line 1: syntax error before: "]}
    end
  end

  describe "run_in_state/4" do
    defmodule Bar do
      use Lua.API

      deflua bar(), lua do
        val = Lua.get_private!(lua, [:private])
        {encoded, lua} = Lua.encode!(lua, val)
        {[encoded], lua}
      end
    end

    test "can access the private variables" do
      state = Scriptengine.State.get_state([Bar])
      res = run_in_state(state, "return bar()", %{}, %{foo: "bar"})
      assert res == {:ok, %{"foo" => "bar"}}
    end
  end

  describe "run/2" do
    test "can accept extra modules to load" do
      res = run("return foo()", context: %{}, extra_modules: [Foo])

      assert res == {:ok, "foo"}
    end
  end
end
