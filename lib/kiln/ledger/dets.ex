defmodule Kiln.Ledger.DETS do
  require Logger
  alias Kiln.Golem

  alias __MODULE__

  ## Config

  defp ets_table_path do
    priv = :code.priv_dir(:kiln)
    File.mkdir_p!(to_string(priv))
    priv ++ '/kiln.dets'
  end

  def all do
    DETS
    |> :dets.match_object(:_)
    |> Enum.map(fn {_id, golem} -> golem end)
  end

  ## Callbacks

  def init do
    if :dets.info(DETS) == :undefined do
      :dets.open_file(DETS, file: ets_table_path())
    end
  end

  def load do
    DETS
    |> :dets.match_object(:_)
    |> Enum.map(fn {_id, golem} -> golem end)
    |> Enum.reject(fn %Golem{status: {type, _}} ->
      case type do
        :completed -> true
        :failed    -> true

        _ -> false
      end
    end)
  end

  def handle_new(%Golem{} = golem) do
    Logger.info("Inserting Golem into DETS")
    :dets.insert(DETS, {golem.id, golem})
  end

  def handle_progress(%Golem{} = golem, _progress) do
    Logger.info("Inserting Golem into DETS")
    :dets.insert(DETS, {golem.id, golem})
  end

  def handle_status(%Golem{} = golem, _status) do
    Logger.info("Inserting Golem into DETS")
    :dets.insert(DETS, {golem.id, golem})
  end

end
