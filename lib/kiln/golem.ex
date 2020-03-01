defmodule Kiln.Golem do
  @moduledoc """
  Documentation for Golem.
  """
  alias __MODULE__

  @type status ::
      {:queued,   priority :: number}
    | {:active,   pid      :: pid   }
    | {:complete, meta     :: any   }
    | {:failure,  reason   :: any   }
    | {:canceled, reason   :: any   }

  @type progress :: {percent :: number, meta :: any}

  defstruct [
    :id,
    :label,

    :status,
    :progress,
    :attempts,
    :failures,

    :args,
    :chem,

    :queued_at,
    :started_at,
    :ended_at
  ]

  @doc """
  Create new golem
  """
  def new(chem, args) do
    %Golem{
      id: UUID.uuid4(),
      label: nil,

      status: nil,
      progress: {0.0, nil},
      attempts: 0,
      failures: [],

      args: args,
      chem: chem,

      queued_at: nil,
      started_at: nil,
      ended_at: nil,
    }
  end

  @doc """
  Determine if golem should be rebaked
  """
  def rebake?(%Golem{} = golem) do
    if golem.attempts >= golem.chem.max_attempts do
      false
    else
      true
    end
  end

end
