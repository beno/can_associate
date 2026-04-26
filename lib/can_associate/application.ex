defmodule CanAssociate.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {CanAssociate.AgentStore, []}
    ]

    opts = [strategy: :one_for_one, name: CanAssociate.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
