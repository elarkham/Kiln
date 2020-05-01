defmodule Kiln.Queue do
  @moduledoc """
  Internal priority queue.

  Only actually stores the golem ids, actual Kiln.Golem metadata is stored
  within internal Kiln.Cache.
  """
  alias Kiln.{Cache, Golem}

  @doc """
  Initializes empty queue
  """
  def new(golems) do
    q = :pqueue.new()
    Enum.reduce(golems, q, fn golem, q ->
      priority = golem.chem.priority

      %Golem{golem |
        status: {:queued, priority},
        progress: {0.0, nil},
        queued_at: DateTime.utc_now,
      }
      |> Cache.upsert

      :pqueue.in(golem.id, priority, q)
    end)
  end

  @doc """
  Enqueues golem id, stores actual golem data in ets cache
  """
  def in_(%Golem{id: id} = golem, q) do
    priority = golem.chem.priority
    Cache.set_status(golem, {:queued, priority})

    :pqueue.in(id, priority, q)
  end

  @doc """
  Dequeue's golem id, then looks id up in cache and returns
  full Kiln.Golem struct
  """
  def out(q) do
    case :pqueue.out(q) do
      {{:value, id}, q} ->
        golem = Cache.lookup(id)
        {{:value, golem}, q}

      {:empty, q} -> {:empty, q}
    end
  end

end
