defmodule Kiln.WorkerSupervisor do
  use ConsumerSupervisor

  @max_demand 8
  @min_demand 1

  def start_link(args) do
    ConsumerSupervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_) do
    child = %{
      id: Kiln.Worker,
      start: {Kiln.Worker, :start_link, []},
      restart: :temporary
    }
    sub_opts = [
      max_demand: @max_demand,
      min_demand: @min_demand,
    ]
    opts = [
      strategy: :one_for_one,
      subscribe_to: [{Kiln.Master, sub_opts}]
    ]
    ConsumerSupervisor.init([child], opts)
  end

end
