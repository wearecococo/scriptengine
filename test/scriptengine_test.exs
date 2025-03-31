defmodule ScriptengineTest do
  use ExUnit.Case
  doctest Scriptengine

  import Scriptengine, only: [run_main: 2]

  describe "run_main/2" do
    test "returns the result of the main function" do
      res = run_main("function main() return 1 + 1; end", %{})
      assert res == {:ok, 2}
    end

    test "returns an error if the main function is not found" do
      res = run_main("function not_main() return 1 + 1; end", %{})
      assert res == {:error, "Lua runtime error: undefined function nil\n\n\n"}
    end
  end
end
