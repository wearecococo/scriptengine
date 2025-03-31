defmodule CococoScript.Extensions.TimeTest do
  use ExUnit.Case

  import Scriptengine, only: [run: 1]

  describe "now/0" do
    test "returns the current time" do
      assert {:ok, res} = run("return time.now()")
      assert {:ok, _, _} = DateTime.from_iso8601(res)
    end
  end

  describe "change/2" do
    test "returns the time with the new value" do
      base = DateTime.utc_now()
      input = DateTime.to_iso8601(base)
      output = base |> DateTime.add(3600)
      {:ok, res} = run("return time.change('#{input}', 3600)")
      assert {:ok, ^output, _} = DateTime.from_iso8601(res)
    end

    test "returns nil with error input timestamp" do
      res = run("return time.change('not a time', 3600)")
      assert res == {:ok, nil}
    end

    test "returns nil with error seconds" do
      res =
        run("return time.change('#{DateTime.to_iso8601(DateTime.utc_now())}', 'not a number')")

      assert res == {:ok, nil}
    end
  end
end
