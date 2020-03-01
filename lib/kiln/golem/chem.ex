defmodule Kiln.Golem.Chem do

  alias Kiln.Golem

  defmacro __using__(opts \\ []) do
    quote bind_quoted: [opts: opts] do
      @after_compile __MODULE__
      @behaviour Kiln.Golem.Chem

      ## Options
      @priority     opts[:priority]     || 0
      @max_attempts opts[:max_attempts] || 0

      def priority,     do: @priority
      def max_attempts, do: @max_attempts

      ## Validate

      def __after_compile__(_env, _bytecode) do

        # Raises error if the Worker doesn't export a perform/1 method
        unless Module.defines?(__MODULE__, {:perform, 2}) do
          raise Kiln.Exception.InvalidChem,
            "#{inspect __MODULE__} does not implement perform/2"
        end


        # Raise error if the concurrency option in invalid
        unless (@max_attempts == :infinity
               or (is_integer(@max_attempts)
               and @max_attempts > 0)) do

          raise Kiln.Exception.InvalidChem,
            "#{inspect __MODULE__} has an invalid max_attempts value"
        end
      end

    end
  end

  @callback perform(golem :: Golem.t, args :: term) :: {:ok, any} | {:error, any}

end
