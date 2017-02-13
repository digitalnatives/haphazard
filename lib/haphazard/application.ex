defmodule Haphazard.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Haphazard.Server, [])
    ]

    opts = [strategy: :one_for_one, name: Haphazard.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
