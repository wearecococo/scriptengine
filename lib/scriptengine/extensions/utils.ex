defmodule Scriptengine.Extensions.Utils do
  use Lua.API, scope: "utils"

  @moduledoc """
  -- Generate a UUID.
  -- @return string: The generated UUID.
  function utils.uuid()
  """

  deflua uuid() do
    UUID.uuid4()
  end
end
