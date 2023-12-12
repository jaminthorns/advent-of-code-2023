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
    |> loop()
    |> length()
    |> div(2)
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

  @test_input_5 """
  FF7FSF7F7F7F7F7F---7
  L|LJ||||||||||||F--J
  FL-7LJLJ||||||LJL-77
  F--JF--7||LJLJIF7FJ-
  L---JF-JLJIIIIFJLJJ7
  |F|F-JF---7IIIL7L|7|
  |FFJF7L7F-JF7IIL---7
  7-L-JL7||F7|L7F-7F7|
  L.L7LFJ|||||FJL7||LJ
  L7JLJL-JLJLJL--JLJ.L
  """

  @doc """
  iex> solve_part_2(#{inspect(@test_input_3)})
  4

  iex> solve_part_2(#{inspect(@test_input_4)})
  8

  iex> solve_part_2(#{inspect(@test_input_5)})
  10
  """
  def solve_part_2(input) do
    grid = grid(input)
    loop = loop(grid)
    inside_edge = inside_edge(loop, grid)

    MapSet.new(inside_edge)
    |> fill(MapSet.new(loop))
    |> tap(&draw(grid, loop, &1))
    |> MapSet.size()
  end

  defp grid(input) do
    for {line, y} <- input |> String.split() |> Enum.with_index(),
        {tile, x} <- line |> String.graphemes() |> Enum.with_index(),
        into: Map.new() do
      {{x, y}, tile}
    end
  end

  defp loop(grid) do
    {start, "S"} = Enum.find(grid, fn {_, tile} -> tile == "S" end)

    # Pick an arbitrary branch to start with.
    branch_head =
      "S"
      |> connections(start)
      |> Enum.find(&(start in connections(grid[&1], &1)))

    # Walk the loop from that branch until we get back to start.
    loop =
      {start, branch_head}
      |> Stream.iterate(fn {prev, pos} -> {pos, next(prev, pos, grid)} end)
      |> Stream.map(&elem(&1, 1))
      |> Enum.take_while(&(&1 != start))
      |> Enum.concat([start])

    [start | loop]
  end

  defp next(previous, position, grid) do
    grid
    |> Map.get(position)
    |> connections(position)
    |> Enum.find(&(&1 != previous))
  end

  defp connections("|", {x, y}), do: [{x, y - 1}, {x, y + 1}]
  defp connections("-", {x, y}), do: [{x - 1, y}, {x + 1, y}]
  defp connections("L", {x, y}), do: [{x, y - 1}, {x + 1, y}]
  defp connections("J", {x, y}), do: [{x, y - 1}, {x - 1, y}]
  defp connections("7", {x, y}), do: [{x, y + 1}, {x - 1, y}]
  defp connections("F", {x, y}), do: [{x, y + 1}, {x + 1, y}]
  defp connections("S", {x, y}), do: [{x - 1, y}, {x + 1, y}, {x, y - 1}, {x, y + 1}]
  defp connections(_, _), do: []

  defp inside_edge(loop, grid) do
    linked_loop = loop |> Enum.drop(1) |> Enum.zip(loop)

    turns =
      linked_loop
      |> Enum.map(fn {current, previous} -> turn_direction(previous, current, grid) end)
      |> Enum.reject(&is_nil/1)

    directionality =
      turns
      |> Enum.frequencies()
      |> Enum.max_by(&elem(&1, 1))
      |> elem(0)

    linked_loop
    |> Enum.map(fn {next, current} ->
      direction = cardinal_direction(current, next)
      direction = rotate_relative(direction, directionality)

      shift_cardinal(current, direction)
    end)
    |> Enum.reject(&(&1 in loop))
    |> Enum.uniq()
  end

  defp turn_direction(previous, current, grid) do
    next = next(previous, current, grid)
    from_direction = cardinal_direction(previous, current)
    to_direction = cardinal_direction(current, next)

    relative_direction(from_direction, to_direction)
  end

  defp fill(seen, border) do
    exclude = MapSet.union(seen, border)
    new = seen |> Enum.flat_map(&adjacent/1) |> MapSet.new() |> MapSet.difference(exclude)
    seen = MapSet.union(seen, new)

    if Enum.empty?(new), do: seen, else: fill(seen, border)
  end

  defp adjacent({x, y}) do
    for dx <- [-1, 0, 1], dy <- [-1, 0, 1], {x, y} != {0, 0} do
      {x + dx, y + dy}
    end
  end

  @cardinal_offsets [
    %{cardinal: :west, offset: {-1, 0}},
    %{cardinal: :east, offset: {1, 0}},
    %{cardinal: :north, offset: {0, -1}},
    %{cardinal: :south, offset: {0, 1}}
  ]

  defp cardinal_direction({x_a, y_a}, {x_b, y_b}) do
    offset = {x_b - x_a, y_b - y_a}

    @cardinal_offsets
    |> Enum.find(&(&1.offset == offset))
    |> Map.get(:cardinal)
  end

  defp shift_cardinal({x, y}, cardinal) do
    {dx, dy} =
      @cardinal_offsets
      |> Enum.find(&(&1.cardinal == cardinal))
      |> Map.get(:offset)

    {x + dx, y + dy}
  end

  @cardinal_directions [
    %{from: :west, to: :north, relative: :right},
    %{from: :west, to: :south, relative: :left},
    %{from: :east, to: :north, relative: :left},
    %{from: :east, to: :south, relative: :right},
    %{from: :north, to: :west, relative: :left},
    %{from: :north, to: :east, relative: :right},
    %{from: :south, to: :west, relative: :right},
    %{from: :south, to: :east, relative: :left}
  ]

  defp relative_direction(cardinal, cardinal), do: nil

  defp relative_direction(from_cardinal, to_cardinal) do
    @cardinal_directions
    |> Enum.find(&(&1.from == from_cardinal and &1.to == to_cardinal))
    |> Map.get(:relative)
  end

  defp rotate_relative(cardinal, relative) do
    @cardinal_directions
    |> Enum.find(&(&1.from == cardinal and &1.relative == relative))
    |> Map.get(:to)
  end

  defp draw(grid, loop, enclosed) do
    IO.write("\n")

    {max_x, max_y} = grid |> Map.keys() |> Enum.max()

    for y <- 0..max_y, x <- 0..max_x do
      char =
        cond do
          {x, y} in enclosed -> "█"
          {x, y} in loop -> grid |> Map.get({x, y}) |> draw_pipe()
          true -> " "
        end

      IO.write(char)

      if x == max_x, do: IO.write("\n")
    end
  end

  defp draw_pipe("|"), do: "│"
  defp draw_pipe("-"), do: "─"
  defp draw_pipe("L"), do: "└"
  defp draw_pipe("J"), do: "┘"
  defp draw_pipe("7"), do: "┐"
  defp draw_pipe("F"), do: "┌"
  defp draw_pipe("S"), do: "S"
end
