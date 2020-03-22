defmodule Kiln.Master do
  @moduledoc """
  Master process that coordinates Kiln and serves as the internal
  GenStage producer.
  """
  use GenStage

  alias Kiln.{
    Golem,
    Queue,
    Cache,
    Ledger,
  }

  ##############
  #   Client   #
  ##############

  @doc """
  Starts and initializes Kiln.Master process.
  """
  def start_link(_opt) do
    GenStage.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @doc """
  Bakes a golem.

  Adds to internal priority queue and returns populated Kiln.Golem struct.
  """
  def bake(%Golem{status: {:failure, _}}), do: :ok
  def bake(%Golem{} = golem) do
    GenStage.call(__MODULE__, {:bake, golem})
  end

  @doc """
  Cancels a golem.

  If golem is already active then it's running process is killed and it's
  status is changed to canceled.

  If golem is still in the queue, it is marked as canceled and skipped when
  it exits the queue.

  If golem is any other status then this function just returns it.
  """
  def cancel(%Golem{id: id}, reason \\ nil) do
    case Cache.lookup(id) do
      %Golem{status: {:active, pid}} = golem ->
        Process.exit(pid, :kill)
        Cache.set_status(golem, {:canceled, reason})

      %Golem{status: {:queued, _}} = golem ->
        Cache.set_status(golem, {:canceled, reason})

      golem -> golem
    end
  end

  ##############
  #   Server   #
  ##############

  # Initializes process as well as it's internal ets cache and priority queue
  def init(:ok) do
    Cache.init
    Ledger.init
    queue = Ledger.load |> Queue.new
    {:producer, {queue, 0}}
  end

  # Adds golem to internal priority queue and sends populated Kiln.Golem struct
  # back to the client process. Then stores given golem in queue until demand
  # from downstream consumer is recieved.
  def handle_call({:bake, golem}, from, {queue, demand}) do
    queue = Queue.in_(golem, queue)
    GenServer.reply(from, Cache.lookup(golem.id))
    dispatch(queue, demand, [])
  end

  # Stores demand until there is a golem to satisfy it
  def handle_demand(incoming, {queue, pending}) do
    dispatch(queue, incoming + pending, [])
  end

  # If no demand then correct list order
  defp dispatch(queue, 0, golems) do
    {:noreply, Enum.reverse(golems), {queue, 0}}
  end

  # Send golems to downstream consumer to satisfy given demand
  defp dispatch(queue, demand, golems) do
    case Queue.out(queue) do
      {{:value, golem}, queue} ->
        dispatch(queue, demand - 1, [golem | golems])

      {:empty, queue} ->
        {:noreply, Enum.reverse(golems), {queue, demand}}
    end
  end

end
