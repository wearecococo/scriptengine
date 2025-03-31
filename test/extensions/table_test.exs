defmodule Scriptengine.Extensions.TableTest do
  use ExUnit.Case
  import Scriptengine, only: [run: 1]

  describe "compact/1" do
    test "compacts a table" do
      res = run("return table.compact({1, null, 3})")
      assert res == {:ok, [1, 3]}
    end
  end

  describe "include/2" do
    test "returns true if the table includes the value" do
      res = run("return table.include({1, 2, 3}, 2)")
      assert res == {:ok, true}
    end
  end

  describe "find_by/3" do
    test "returns nil if the table is nil" do
      res = run("return table.find_by(nil, 'foo', 'bar')")
      assert res == {:ok, nil}
    end

    test "returns nil if the table is not a table" do
      res = run("return table.find_by('not a table', 'foo', 'bar')")
      assert res == {:ok, nil}
    end

    test "finds a value by a field" do
      res =
        run("return table.find_by({{foo = 'bar'}, {foo = 'qux'}}, 'foo', 'qux')")

      assert res == {:ok, %{"foo" => "qux"}}
    end
  end

  describe "max_by/2" do
    test "returns the value with the highest field" do
      res = run("return table.max_by({{foo = 1}, {foo = 2}}, 'foo')")
      assert res == {:ok, %{"foo" => 2}}
    end

    test "returns nil if the table is nil" do
      res = run("return table.max_by(nil, 'foo')")
      assert res == {:ok, nil}
    end
  end

  describe "max_value_by/2" do
    test "returns the value with the highest field" do
      res = run("return table.max_value_by({{foo = 1}, {foo = 2}}, 'foo')")
      assert res == {:ok, 2}
    end

    test "returns nil if the table is nil" do
      res = run("return table.max_value_by(nil, 'foo')")
      assert res == {:ok, nil}
    end

    test "returns nil if the table is not a table" do
      res = run("return table.max_value_by('not a table', 'foo')")
      assert res == {:ok, nil}
    end
  end

  describe "uniq/1" do
    test "returns the unique values in the table" do
      res = run("return table.uniq({1, 2, 2, 3})")
      assert res == {:ok, [1, 2, 3]}
    end

    test "returns nil if the table is nil" do
      res = run("return table.uniq(nil)")
      assert res == {:ok, nil}
    end

    test "returns nil if the table is not a table" do
      res = run("return table.uniq('not a table')")
      assert res == {:ok, nil}
    end
  end

  describe "uniq_by/2" do
    test "returns the unique values in the table by a field" do
      res =
        run("return table.uniq_by({{foo = 1}, {foo = 2}, {foo = 2}, {foo = 3}}, 'foo')")

      assert res == {:ok, [%{"foo" => 1}, %{"foo" => 2}, %{"foo" => 3}]}
    end

    test "returns nil if the table is nil" do
      res = run("return table.uniq_by(nil, 'foo')")
      assert res == {:ok, nil}
    end

    test "returns nil if the table is not a table" do
      res = run("return table.uniq_by('not a table', 'foo')")
      assert res == {:ok, nil}
    end
  end

  describe "pluck/2" do
    test "returns the values of a field in the table" do
      res =
        run("return table.pluck({{foo = 1}, {foo = 2}, {foo = 3}}, 'foo')")

      assert res == {:ok, [1, 2, 3]}
    end

    test "returns nil if the table is nil" do
      res = run("return table.pluck(nil, 'foo')")
      assert res == {:ok, nil}
    end

    test "returns nil if the table is not a table" do
      res = run("return table.pluck('not a table', 'foo')")
      assert res == {:ok, nil}
    end
  end
end
