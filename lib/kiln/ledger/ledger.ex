defmodule Kiln.Ledger do
  require Logger
  alias Kiln.Golem

  defmacro __using__(opts \\ []) do
    quote bind_quoted: [opts: opts] do
      @behaviour Kiln.Ledger

      ## Defaults
      def init, do: :ok
      def load, do: []

      def handle_new(%Golem{} = golem), do: golem

      def handle_progress(%Golem{} = golem, progress), do: golem

      def handle_status(%Golem{} = golem, status), do: golem

      defoverridable [
        init: 0,
        load: 0,
        handle_new: 1,
        handle_progress: 2,
        handle_status: 2,
      ]
    end
  end

  @callback init() :: any()
  @callback load() :: [Golem.t]

  @callback handle_new(golem :: Golem.t) :: any()

  @callback handle_progress(golem :: Golem.t, Golem.progress) :: any()

  @callback handle_status(golem :: Golem.t, Golem.status) :: any()

  ## Config

  defp ledger do
    Application.get_env(:kiln, :ledger)
      || raise Kiln.Exception.MissingLedger,
          "No Ledger Module In Application Config"
  end


  ## Callbacks

  def init do
    Logger.info("Initializing Ledger")
    apply(ledger(), :init, [])
  end

  def load do
    Logger.info("Loading From Ledger")
    apply(ledger(), :load, [])
  end

  def handle_new(%Golem{} = golem) do
    Logger.info("New golem :: #{golem.id}")
    apply(ledger(), :handle_new, [golem])
    golem
  end

  def handle_progress(%Golem{} = golem, progress) do
    #Logger.info("Progress Update :: #{golem.id} ::  #{inspect progress}")
    apply(ledger(), :handle_progress, [golem, progress])
    golem
  end

  def handle_status(%Golem{} = golem, status) do
    Logger.info("Status Update :: #{golem.id} :: #{inspect status}")
    apply(ledger(), :handle_status, [golem, status])
    golem
  end

end
