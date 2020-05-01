defmodule Kiln.Cache do
  @moduledoc """
  Serves as interface to internal ETS table that tracks golem state
  during runtime
  """
  alias Kiln.{Golem, Ledger}

  ###############
  #   General   #
  ###############

  @doc """
  Initializes ETS table
  """
  def init do
    :ets.new(Kiln.Cache, [:set, :public, :named_table])
  end

  @doc """
  Returns all golems within the cache
  """
  def all do
    :ets.tab2list(Kiln.Cache)
    |> Enum.map(fn {_id, golem} -> golem end)
  end

  @doc """
  Returns golems with specified status type
  """
  def all(status_type) do
    :ets.tab2list(Kiln.Cache)
    |> Enum.map(fn {_id, golem} -> golem end)
    |> Enum.filter(fn %{status: {type, _}} -> type == status_type end)
  end

  @doc """
  Gets golem with given id
  """
  def lookup(id) do
    [{_id, golem}] = :ets.lookup(Kiln.Cache, id)
    golem
  end

  @doc """
  Adds golem to ets, overwriting anything with same id
  """
  def upsert(%Golem{id: id} = golem) do
    :ets.insert(Kiln.Cache, {id, golem})
    golem
  end

  ########################
  #   Progress Changes   #
  ########################

  @doc """
  Updates golem progress
  """
  def set_progress(%Golem{id: id}, {percent, meta})
    when is_number(percent) do

    %Golem{lookup(id) |
      progress: {percent, meta}
    }
    |> upsert
    |> Ledger.handle_progress({percent, meta})
  end

  ######################
  #   Status Changes   #
  ######################

  def set_status(%Golem{} = golem, {:queued, priority} = status)
    when is_integer(priority) do

    %Golem{golem |
      status: {:queued, priority},
      progress: {0.0, nil},
      queued_at: DateTime.utc_now,
    }
    |> upsert
    |> Ledger.handle_status(status)
  end

  def set_status(%Golem{} = golem, {:active, pid} = status)
    when is_pid(pid) do

    %Golem{golem |
      status: {:active, pid},
      started_at: DateTime.utc_now,
    }
    |> upsert
    |> Ledger.handle_status(status)
  end

  def set_status(%Golem{} = golem, {:completed, meta} = status) do
    %Golem{golem |
      status: {:completed, meta},
      attempts: golem.attempts + 1,
      ended_at: DateTime.utc_now
    }
    |> upsert
    |> Ledger.handle_status(status)
  end

  def set_status(%Golem{} = golem, {:failed, reason} = status) do
    if (golem.attempts + 1) >= golem.chem.max_attempts do
      set_failed(golem, reason) # won't be rebaked
    else
      add_failure(golem, reason) # will be rebaked
    end
    |> upsert
    |> Ledger.handle_status(status)
  end

  def set_status(%Golem{} = golem, {:canceled, reason} = status) do
     %Golem{golem |
      status: {:canceled, reason},
      attempts: golem.attempts + 1,
      ended_at: DateTime.utc_now,
    }
    |> upsert
    |> Ledger.handle_status(status)
  end

  def set_status(%Golem{}, status) do
    raise Kiln.Exception.InvalidStatus,
      "Given status is invalid: #{inspect status}"
  end

  ###############
  #   Helpers   #
  ###############

  def set_failed(%Golem{} = golem, reason) do
    ended_at = DateTime.utc_now
    failure = %{
      reason: reason,
      progress: golem.progress,
      started_at: golem.started_at,
      failed_at: ended_at,
    }

    %Golem{golem |
      status: {:failed, reason},
      attempts: golem.attempts + 1,
      failures: [failure | golem.failures],
      ended_at: ended_at
    }
  end

  def add_failure(%Golem{} = golem, reason) do
    failure = %{
      reason: reason,
      progress: golem.progress,
      started_at: golem.started_at,
      failed_at: DateTime.utc_now,
    }

    %Golem{golem |
      status: {:queued, nil},
      attempts: golem.attempts + 1,
      failures: [failure | golem.failures]
    }
  end

end
