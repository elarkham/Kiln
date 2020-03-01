defmodule Kiln.Exception do

  defmodule InvalidStatus do
    defexception [:message]
    @moduledoc false
  end

  defmodule InvalidChem do
    defexception [:message]
    @moduledoc false
  end

  defmodule MissingLedger do
    defexception [:message]
    @moduledoc false
  end

end
