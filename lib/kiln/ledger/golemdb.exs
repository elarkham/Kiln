defmodule Kiln.Ledger.Ecto.GolemDB do
  use Ecto.Schema

  alias Kiln.Ledger.Type
  alias Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: false}
  schema "_golem" do
    field :label,     :string

    field :status_type,  Type.Atom
    field :status_meta,  Type.Any

    field :progress_percent, :float
    field :progress_meta,    Type.Any

    field :attempts,  :integer
    field :failures,  Type.Any

    field :args, Type.Any
    field :chem  Type.Atom

    field :queued_at,  :utc_datetime
    field :started_at, :utc_datetime
    field :ended_at,   :utc_datetime
  end

  def to_golemdb(%Golem{} = golem) do
    fields = Map.keys(golem)

    %Golem{
      status: {status_type, status_meta},
      progress: {progress_percent, progress_meta},
    } = golem


    params = %{
      id: golem.id,
      label: golem.label,

      status_type: status_type,
      status_meta: status_meta,

      progress_percent: progress_percent,
      progress_meta: progress_meta,

      attempts: golem.attempts,
      failures: golem.failures,

      args: golem.args,
      chem: golem.chem,

      queued_at: golem.queued_at,
      started_at: golem.started_at,
      ended_at: golem.ended_at,
    }

    Ecto.Changeset.cast(%GolemDB{}, params, fields)
  end

  def from_golemdb(%GolemDB{} = golemdb) do
    %Golem{
      id: golemdb.id,
      label: golemdb.label,

      status: {golemdb.status_type, golemdb.status_meta}
      progress: {golemdb.progress_percent, golemdb.progress_meta}

      attempts: golemdb.attempts,
      failures: golemdb.failures,

      args: golemdb.args,
      chem: golemdb.chem,

      queued_at: golemdb.queued_at,
      started_at: golemdb.started_at,
      ended_at: golemdb.ended_at,
    }
  end

end
