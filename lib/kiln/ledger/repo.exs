defmodule Kiln.Ledger.Repo do
  @moduledoc """
  Golem Repo
  """
  use Ecto.Repo,
    otp_app: :golem,
    adapter: Ecto.Adapters.Postgres
end
