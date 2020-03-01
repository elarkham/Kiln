defmodule Kiln.Ledger.Ecto do
  use Kiln.Ledger

  import Ecto.Query, only: [from: 2]
  alias Kiln.Ledger.GolemDB

  #################
  #   Callbacks   #
  #################

  #def init do
  #end

  def load do
    query = from(
      g in GolemDB,
      where: g.status_type == "active",
      or_where: g.status_type == "queued",
      select: g
    )
    |> Repo.all
    |> Enum.map(&from_golemdb/1)
  end

  def handle_new(%Golem{} = golem) do
    golem
    |> to_golemdb
    |> Repo.insert!
  end

  #def handle_progress(%Golem{} = golem, _progress) do
  #end

  def handle_status(%Golem{} = golem, _status) do
    golem
    |> to_golemdb
    |> Repo.insert!
  end

end
