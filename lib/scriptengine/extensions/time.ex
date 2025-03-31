defmodule Scriptengine.Extensions.Time do
  use Lua.API, scope: "time"

  @moduledoc """
  -- Get the current time.
  -- @return string: The current time in ISO 8601 format  .
  function time.now()

  -- Get the current time in Unix timestamp format.
  -- @return number: The current time in Unix timestamp format.
  function time.unix_now()

  -- Change a time by a number of seconds.
  -- @param time string: The time to change.
  -- @param seconds number: The number of seconds to change the time by.
  -- @return string: The changed time in ISO 8601 format.
  function time.change(time, seconds)

  -- Convert a time in ISO 8601 format to a Unix timestamp.
  -- @param time string: The time to convert.
  -- @return number: The time in Unix timestamp format.
  function time.to_unix(time)
  """

  deflua now() do
    DateTime.utc_now() |> DateTime.to_iso8601()
  end

  deflua unix_now() do
    DateTime.utc_now() |> DateTime.to_unix()
  end

  deflua change(time, seconds) when is_binary(time) and is_integer(seconds) do
    with {:ok, time, _} <- DateTime.from_iso8601(time) do
      DateTime.add(time, seconds, :second) |> DateTime.to_iso8601()
    else
      _ -> nil
    end
  end

  deflua change(_, _) do
    nil
  end

  deflua to_unix(time) when is_binary(time) do
    with {:ok, time, _} <- DateTime.from_iso8601(time) do
      DateTime.to_unix(time)
    else
      _ -> nil
    end
  end

  deflua to_unix(_) do
    nil
  end
end
