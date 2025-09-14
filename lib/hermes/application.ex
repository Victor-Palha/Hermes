defmodule Hermes.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Hermes.HermesConsumer, []}
    ]

    opts = [strategy: :one_for_one, name: Hermes.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
