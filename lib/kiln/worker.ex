defmodule Kiln.Worker do
  @moduledoc false
  use Task, restart: :temporary

  alias Kiln.{Master, Cache, Golem}

  @wormhole_opts [
    timeout: :infinity,
    ok_tuple: true,
    stacktrace: true,
    #skip_log: true,
  ]

  def start_link(arg) do
    Task.start_link(__MODULE__, :work, [arg])
  end

  # Runs golem within wormhole to capture and report all potential
  # runtime issues. If there is a failure then it's sent back to
  # the master process to be rebaked.
  def work(%Golem{status: {:canceled, _}} = golem), do: golem
  def work(%Golem{} = golem) do
    golem = Cache.set_status(golem, {:active, self()})

    golem.chem
    |> Wormhole.capture(:perform, [golem, golem.args], @wormhole_opts)
    |> handle_result(golem)
  end

  def handle_result({:ok, meta}, golem) do
    golem.id
    |> Cache.lookup
    |> Cache.set_status({:complete, meta})
  end
  def handle_result({:error, reason}, golem) do
    golem =
      golem.id
      |> Cache.lookup
      |> Cache.set_status({:failure, reason})

    if Golem.rebake?(golem) do
      Master.bake(golem)
    end
  end

end
