defmodule Kiln do
  @moduledoc """
  Documentation for Kiln.
  """
  alias __MODULE__

  alias Kiln.{Master, Cache, Golem}

  @doc """
  Create and add new golem to queue
  """
  def bake(chem, args, opt \\ [])
  def bake(chem, args, opt) do
    label = Keyword.get(opt, :label, nil)
    golem = %Golem{
      id: UUID.uuid4(),
      label: label,

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

    Master.bake(golem)

    {:ok, golem}
  end

  def cancel(id, reason \\ nil)
  def cancel(%Golem{} = golem, reason) do
    Master.cancel(golem, reason)
  end
  def cancel(id, reason) do
    Master.cancel(%Golem{id: id}, reason)
  end


  def set_progress(%Golem{} = golem, {progress, meta}) do
    Cache.set_progress(golem, {progress, meta})
  end
  def set_progress(%Golem{} = golem, percent, meta \\ nil) do
    Cache.set_progress(golem, {percent, meta})
  end

end
