defmodule CococoScript.Extensions.UtilsTest do
  use ExUnit.Case

  import Scriptengine, only: [run_chunk: 2]

  describe "uuid/0" do
    test "returns a list with one uuid" do
      res = run_chunk("return utils.uuid()", %{})
      assert {:ok, _} = UUID.info(res)
    end
  end
end
