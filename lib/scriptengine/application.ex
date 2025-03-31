defmodule Scriptengine.Application do
  use Application

  def start(_type, _args) do
    children = [
      {Scriptengine.State, name: Scriptengine.State},
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end