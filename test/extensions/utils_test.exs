defmodule CococoScript.Extensions.UtilsTest do
  use ExUnit.Case

  import Scriptengine, only: [run_in_state: 2]

  setup do
    state = Scriptengine.State.get_state([Scriptengine.Extensions.Utils])
    %{state: state}
  end

  describe "uuid/0" do
    test "returns a list with one uuid", %{state: state} do
      {:ok, res} = run_in_state(state, "return utils.uuid()")
      assert {:ok, _} = UUID.info(res)
    end
  end
end
