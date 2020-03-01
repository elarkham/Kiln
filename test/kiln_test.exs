defmodule KilnTest do
  use ExUnit.Case
  doctest Kiln

  test "greets the world" do
    assert Kiln.hello() == :world
  end
end
