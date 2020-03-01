defmodule Test do
  use Kiln.Golem.Chem, [max_attempts: 2, priority: 5]

  def perform(golem, to: to, from: from, body: body) do
    IO.puts "TO: #{to}"
    IO.puts "FROM: #{from}"
    IO.puts "BODY: #{body}"
    IO.inspect golem
    {:ok, "Thanks Fren"}
  end

  def perform(golem, :clock) do
    n = 30
    for i <- 1..n do
      Process.sleep(1000)
      Kiln.set_progress(golem, (i / n), "Time Left")
    end
    {:ok, nil}
  end

  def perform(golem, _) do
    raise "tadaa"
  end

end
