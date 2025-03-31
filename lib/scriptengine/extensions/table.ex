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

  deflua compact(enum) do
    [enum |> to_elixir() |> Enum.reject(&is_nil/1)]
  end

  deflua include(enum, term) do
    [enum |> to_elixir() |> Enum.member?(to_elixir(term))]
  end

  deflua find_by(table, field, term) when is_list(table) do
    field = to_elixir(field)
    term = to_elixir(term)

    value =
      table
      |> to_elixir()
      |> Enum.find(fn item -> item[field] == term end)

    [value]
  end

  deflua find_by(_table, _field, _term) do
    []
  end

  deflua max_by(table, field) when is_list(table) do
    field = to_elixir(field)

    table
    |> to_elixir()
    |> Enum.max_by(fn
      %{} = i -> Map.get(i, field)
      i when is_number(i) -> i
      _ -> 0
    end)
  end

  deflua max_by(_table, _field) do
    nil
  end

  deflua max_value_by(table, field) when is_list(table) do
    field = to_elixir(field)

    value =
      table
      |> to_elixir()
      |> Enum.max_by(fn
        %{} = i -> Map.get(i, field)
        i when is_number(i) -> i
        _ -> 0
      end)

    case value do
      %{} -> Map.get(value, field)
      _ -> value
    end
  end

  deflua max_value_by(_table, _field) do
    nil
  end

  deflua uniq(table) when is_list(table) do
    table
    |> to_elixir()
    |> Enum.uniq()
  end

  deflua uniq(_table) do
    []
  end

  deflua uniq_by(table, field) when is_list(table) do
    field = to_elixir(field)

    table
    |> to_elixir()
    |> Enum.uniq_by(fn
      %{} = i -> Map.get(i, field)
      _ -> nil
    end)
  end

  deflua uniq_by(_table, _field) do
    []
  end

  deflua pluck(table, field) when is_list(table) do
    field = to_elixir(field)

    table
    |> to_elixir()
    |> Enum.map(fn %{} = i -> Map.get(i, field) end)
  end

  deflua pluck(_table, _field) do
    []
  end
end
