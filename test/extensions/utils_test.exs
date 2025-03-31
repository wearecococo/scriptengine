defmodule CococoScript.Extensions.UtilsTest do
  use ExUnit.Case

  import Scriptengine, only: [run: 1]

  describe "uuid/0" do
    test "returns a list with one uuid" do
      {:ok, res} = run("return utils.uuid()")
      assert {:ok, _} = UUID.info(res)
    end
  end
end
