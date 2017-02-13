defmodule Haphazard.Application do
  @moduledoc """
  Starts up the Haphazard application
  """
  use Application

  @spec start(any(), any()) :: Supervisor.on_start
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Haphazard.Server, [])
    ]

    opts = [strategy: :one_for_one, name: Haphazard.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
