defmodule CococoScript.Extensions.TimeTest do
  use ExUnit.Case

  import Scriptengine, only: [run_in_state: 2]

  setup do
    state = Scriptengine.State.get_state([Scriptengine.Extensions.Time])
    %{state: state}
  end

  describe "now/0" do
    test "returns the current time", %{state: state} do
      assert {:ok, res} = run_in_state(state, "return time.now()")
      assert {:ok, _, _} = DateTime.from_iso8601(res)
    end
  end

  describe "change/2" do
    test "returns the time with the new value", %{state: state} do
      base = DateTime.utc_now()
      input = DateTime.to_iso8601(base)
      output = base |> DateTime.add(3600)
      {:ok, res} = run_in_state(state, "return time.change('#{input}', 3600)")
      assert {:ok, ^output, _} = DateTime.from_iso8601(res)
    end

    test "returns nil with error input timestamp", %{state: state} do
      res = run_in_state(state, "return time.change('not a time', 3600)")
      assert res == {:ok, nil}
    end

    test "returns nil with error seconds", %{state: state} do
      res =
        run_in_state(
          state,
          "return time.change('#{DateTime.to_iso8601(DateTime.utc_now())}', 'not a number')"
        )

      assert res == {:ok, nil}
    end
  end
end
