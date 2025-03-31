defmodule ScriptengineTest do
  use ExUnit.Case
  doctest Scriptengine

  import Scriptengine, only: [run: 2]

  defmodule Foo do
    use Lua.API

    deflua foo() do
      ["foo"]
    end
  end

  describe "run/2" do
    test "returns the result of the script" do
      res = run("return 1 + 1", context: %{})
      assert res == {:ok, 2}
    end

    test "can access the context" do
      res = run("return context.params.foo", context: %{"foo" => "bar"})
      assert res == {:ok, "bar"}
    end

    test "returns an error if code is not valid" do
      res = run("function not_main()", context: %{})
      assert res == {:error, ["Line 1: syntax error before: "]}
    end

    test "can accept extra modules to load" do
      res =
        run("return foo()",
          context: %{},
          extra_modules: [Foo]
        )

      assert res == {:ok, "foo"}
    end
  end
end
