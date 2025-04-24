defmodule Scriptengine.Extensions.Table do
  use Lua.API, scope: "table"
  import Scriptengine.Utils

  @moduledoc """
  -- Compact a table removing nil values.
  -- @param enum table: The table to compact.
  -- @return table: The compacted table.
  function table.compact(enum)

  -- Check if a table includes a term.
  -- @param enum table: The table to check.
  -- @param term any: The term to check for.
  -- @return boolean: Whether the table includes the term.
  function table.include(enum, term)

  -- Find an item in a table of tables by a field and term.
  -- @param enum table: The table to search.
  -- @param field string: The field to search by.
  -- @param term any: The term to search for.
  -- @return table | number: The found item.
  function table.find_by(enum, field, term)

  -- Get the maximum value in a table or table of tables by a field.
  -- @param table table: The table to search.
  -- @param field string: The field to search by.
  -- @return number: The maximum value.
  function table.max_by(table, field)

  -- Get the maximum value in a table or table of tables by a field.
  -- @param table table: The table to search.
  -- @param field string: The field to search by.
  -- @return number: The maximum value.
  function table.max_value_by(table, field)

  -- Remove duplicates from a table.
  -- @param table table: The table to remove duplicates from.
  -- @return table: The table with duplicates removed.
  function table.uniq(table)

  -- Remove duplicates from a table by a field.
  -- @param table table: The table to remove duplicates from.
  -- @param field string: The field to remove duplicates by.
  -- @return table: The table with duplicates removed.
  function table.uniq_by(table, field)

  -- Pluck a field from a table.
  -- @param table table: The table to pluck from.
  -- @param field string: The field to pluck.
  -- @return table: The plucked field.
  function table.pluck(table, field)
  """

  deflua compact({:tref, tref}), lua do
    table = :luerl.decode({:tref, tref}, lua.state)
    compacted = table |> to_elixir() |> Enum.reject(&is_nil/1)
    {encoded, lua} = Lua.encode!(lua, compacted)
    {[encoded], lua}
  end

  deflua compact(enum), lua do
    res = enum |> to_elixir() |> Enum.reject(&is_nil/1)
    {encoded, lua} = Lua.encode!(lua, res)
    {[encoded], lua}
  end

  deflua include({:tref, tref}, term), lua do
    table = :luerl.decode({:tref, tref}, lua.state)
    res = table |> to_elixir() |> Enum.member?(to_elixir(term))
    {encoded, lua} = Lua.encode!(lua, res)
    {[encoded], lua}
  end

  deflua include(enum, term), lua do
    res = enum |> to_elixir() |> Enum.member?(to_elixir(term))
    {encoded, lua} = Lua.encode!(lua, res)
    {[encoded], lua}
  end

  deflua find_by([_ | _] = table, field, term), lua do
    field = to_elixir(field)
    term = to_elixir(term)

    value =
      table
      |> to_elixir()
      |> Enum.find(fn item -> item[field] == term end)

    {[value], lua}
  end

  deflua find_by({:tref, tref}, field, term), lua do
    table = :luerl.decode({:tref, tref}, lua.state)
    field = to_elixir(field)
    term = to_elixir(term)

    value =
      table
      |> to_elixir()
      |> Enum.find(fn item -> item[field] == term end)

    {encoded, lua} = Lua.encode!(lua, value)
    {[encoded], lua}
  end

  deflua find_by(_table, _field, _term), lua do
    {[nil], lua}
  end

  deflua max_by([_ | _] = table, field), lua do
    field = to_elixir(field)

    value =
      table
      |> to_elixir()
      |> Enum.max_by(fn
        %{} = i -> Map.get(i, field)
        i when is_number(i) -> i
        _ -> 0
      end)

    {encoded, lua} = Lua.encode!(lua, value)
    {[encoded], lua}
  end

  deflua max_by({:tref, tref}, field), lua do
    table = :luerl.decode({:tref, tref}, lua.state)
    field = to_elixir(field)

    value =
      table
      |> to_elixir()
      |> Enum.max_by(fn
        %{} = i -> Map.get(i, field)
        i when is_number(i) -> i
        _ -> 0
      end)

    {encoded, lua} = Lua.encode!(lua, value)
    {[encoded], lua}
  end

  deflua max_by(_table, _field), lua do
    {[nil], lua}
  end

  deflua max_value_by([_ | _] = table, field), lua do
    field = to_elixir(field)

    value =
      table
      |> to_elixir()
      |> Enum.max_by(fn
        %{} = i -> Map.get(i, field)
        i when is_number(i) -> i
        _ -> 0
      end)
      |> case do
        %{} = v -> Map.get(v, field)
        v -> v
      end

    {encoded, lua} = Lua.encode!(lua, value)
    {[encoded], lua}
  end

  deflua max_value_by({:tref, tref}, field), lua do
    table = :luerl.decode({:tref, tref}, lua.state)
    field = to_elixir(field)

    value =
      table
      |> to_elixir()
      |> Enum.max_by(fn
        %{} = i -> Map.get(i, field)
        i when is_number(i) -> i
        _ -> 0
      end)
      |> case do
        %{} = v -> Map.get(v, field)
        v -> v
      end

    {encoded, lua} = Lua.encode!(lua, value)
    {[encoded], lua}
  end

  deflua max_value_by(_table, _field), lua do
    {[nil], lua}
  end

  deflua uniq([_ | _] = table), lua do
    res = table |> to_elixir() |> Enum.uniq()
    {encoded, lua} = Lua.encode!(lua, res)
    {[encoded], lua}
  end

  deflua uniq({:tref, tref}), lua do
    table = :luerl.decode({:tref, tref}, lua.state)
    res = table |> to_elixir() |> Enum.uniq()
    {encoded, lua} = Lua.encode!(lua, res)
    {[encoded], lua}
  end

  deflua uniq(_table), lua do
    {[nil], lua}
  end

  deflua uniq_by([_ | _] = table, field), lua do
    field = to_elixir(field)

    res =
      table
      |> to_elixir()
      |> Enum.uniq_by(fn
        %{} = i -> Map.get(i, field)
        _ -> nil
      end)

    {res, lua}
  end

  deflua uniq_by({:tref, tref}, field), lua do
    table = :luerl.decode({:tref, tref}, lua.state)
    field = to_elixir(field)

    value =
      table
      |> to_elixir()
      |> Enum.uniq_by(fn
        %{} = i -> Map.get(i, field)
        _ -> nil
      end)

    {encoded, lua} = Lua.encode!(lua, value)
    {[encoded], lua}
  end

  deflua uniq_by(_table, _field), lua do
    {[], lua}
  end

  deflua pluck([_ | _] = table, field), lua do
    field = to_elixir(field)

    res =
      table
      |> to_elixir()
      |> Enum.map(fn %{} = i -> Map.get(i, field) end)

    {res, lua}
  end

  deflua pluck({:tref, tref}, field), lua do
    table = :luerl.decode({:tref, tref}, lua.state)
    field = to_elixir(field)

    res =
      table
      |> to_elixir()
      |> Enum.map(fn %{} = i -> Map.get(i, field) end)

    {res, lua}
  end

  deflua pluck(_table, _field), lua do
    {[], lua}
  end
end
