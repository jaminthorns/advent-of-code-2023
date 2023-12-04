defmodule Solution do
  @callback solve_part_1(input :: binary) :: any
  @callback solve_part_2(input :: binary) :: any

  @doc """
  Solve a puzzle for a given `day` and `part`.
  """
  def solve(day, part) do
    module = Module.concat(["Solutions", "Day#{day}"])
    input = File.read!("input/day_#{day}.txt")

    case part do
      1 -> module.solve_part_1(input)
      2 -> module.solve_part_2(input)
    end
  end
end
