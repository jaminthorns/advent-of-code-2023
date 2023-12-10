defmodule Solutions.Day10 do
  @behaviour Solution

  @test_input_1 """
  .....
  .S-7.
  .|.|.
  .L-J.
  .....
  """

  @test_input_2 """
  ..F7.
  .FJ|.
  SJ.L7
  |F--J
  LJ...
  """

  @doc """
  iex> solve_part_1(#{inspect(@test_input_1)})
  4

  iex> solve_part_1(#{inspect(@test_input_2)})
  8
  """
  def solve_part_1(input) do
    input
    |> grid()
    |> farthest_distance()
  end

  @test_input_3 """
  ...........
  .S-------7.
  .|F-----7|.
  .||.....||.
  .||.....||.
  .|L-7.F-J|.
  .|..|.|..|.
  .L--J.L--J.
  ...........
  """

  @test_input_4 """
  .F----7F7F7F7F-7....
  .|F--7||||||||FJ....
  .||.FJ||||||||L7....
  FJL7L7LJLJ||LJ.L-7..
  L--J.L7...LJS7F-7L7.
  ....F-J..F7FJ|L7L7L7
  ....L7.F7||L7|.L7L7|
  .....|FJLJ|FJ|F7|.LJ
  ....FJL-7.||.||||...
  ....L---J.LJ.LJLJ...
  """

  @doc """
  iex> solve_part_2(#{inspect(@test_input_3)})
  4

  iex> solve_part_2(#{inspect(@test_input_4)})
  10
  """
  def solve_part_2(input) do
    input
    |> grid()
    |> enclosed_count()
  end

  defp grid(input) do
    for {line, y} <- input |> String.split() |> Enum.with_index(),
        {tile, x} <- line |> String.graphemes() |> Enum.with_index(),
        into: Map.new() do
      {{x, y}, tile}
    end
  end

  defp farthest_distance(grid) do
    {start, "S"} = Enum.find(grid, fn {_, tile} -> tile == "S" end)

    "S"
    |> connections(start)
    |> Enum.filter(&(start in connections(grid[&1], &1)))
    |> Enum.map(&{start, &1})
    |> Stream.iterate(&Enum.flat_map(&1, fn {prev, pos} -> step(prev, pos, grid) end))
    |> Enum.find_index(fn steps -> steps |> Enum.map(&elem(&1, 1)) |> Util.same?() end)
    |> Kernel.+(1)
  end

  defp step(previous, position, grid) do
    grid
    |> Map.get(position)
    |> connections(position)
    |> Enum.reject(&(&1 == previous))
    |> Enum.map(&{position, &1})
  end

  defp enclosed_count(_grid) do
    nil
  end

  defp connections("|", {x, y}), do: [{x, y - 1}, {x, y + 1}]
  defp connections("-", {x, y}), do: [{x - 1, y}, {x + 1, y}]
  defp connections("L", {x, y}), do: [{x, y - 1}, {x + 1, y}]
  defp connections("J", {x, y}), do: [{x, y - 1}, {x - 1, y}]
  defp connections("7", {x, y}), do: [{x, y + 1}, {x - 1, y}]
  defp connections("F", {x, y}), do: [{x, y + 1}, {x + 1, y}]
  defp connections("S", {x, y}), do: [{x - 1, y}, {x + 1, y}, {x, y - 1}, {x, y + 1}]
  defp connections(_, _), do: []
end
