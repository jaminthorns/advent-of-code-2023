defmodule Solutions.Day3 do
  @behaviour Solution

  @digits Enum.map(0..9, &to_string/1)

  @test_input """
  467..114..
  ...*......
  ..35..633.
  ......#...
  617*......
  .....+.58.
  ..592.....
  ......755.
  ...$.*....
  .664.598..
  """

  @doc """
  iex> solve_part_1(#{inspect(@test_input)})
  4361
  """
  def solve_part_1(input) do
    input
    |> schematic()
    |> part_numbers()
    |> Enum.sum()
  end

  @doc """
  iex> solve_part_2(#{inspect(@test_input)})
  467835
  """
  def solve_part_2(input) do
    input
    |> schematic()
    |> gear_part_numbers()
    |> Enum.map(fn [number_a, number_b] -> number_a * number_b end)
    |> Enum.sum()
  end

  defp schematic(input) do
    input
    |> String.split()
    |> Enum.with_index()
    |> Enum.map(fn {line, y} -> schematic_line(line, y) end)
    |> Enum.reduce(&Map.merge(&1, &2, fn _key, a, b -> Enum.concat(a, b) end))
  end

  defp schematic_line(line, y, x \\ 0, state \\ %{numbers: [], symbols: []}) do
    case {parse_unsigned(line), line} do
      {{value, rest}, _} ->
        span = value |> Integer.digits() |> length()
        number = %{number: value, start_x: x, end_x: x + span - 1, y: y}

        schematic_line(rest, y, x + span, %{state | numbers: [number | state.numbers]})

      {:error, "." <> rest} ->
        schematic_line(rest, y, x + 1, state)

      {:error, <<character::binary-size(1)>> <> rest} ->
        symbol = %{symbol: character, x: x, y: y}

        schematic_line(rest, y, x + 1, %{state | symbols: [symbol | state.symbols]})

      {:error, ""} ->
        state
    end
  end

  defp parse_unsigned(string, digits \\ []) do
    with <<digit::binary-size(1)>> <> rest when digit in @digits <- string do
      parse_unsigned(rest, digits ++ [String.to_integer(digit)])
    else
      _ -> if Enum.empty?(digits), do: :error, else: {Integer.undigits(digits), string}
    end
  end

  defp part_numbers(%{numbers: numbers, symbols: symbols}) do
    numbers
    |> Enum.filter(fn %{start_x: start_x, end_x: end_x, y: y} ->
      adjacent = adjacent_positions(start_x, end_x, y)
      Enum.any?(symbols, &({&1.x, &1.y} in adjacent))
    end)
    |> Enum.map(& &1.number)
  end

  defp gear_part_numbers(%{numbers: numbers, symbols: symbols}) do
    symbols
    |> Enum.filter(&(&1.symbol == "*"))
    |> Enum.map(fn %{x: x, y: y} ->
      adjacent = adjacent_positions(x, x, y)

      numbers
      |> Enum.filter(&adjacent_number?(&1, adjacent))
      |> Enum.map(& &1.number)
    end)
    |> Enum.filter(&(length(&1) == 2))
  end

  defp adjacent_number?(%{start_x: start_x, end_x: end_x, y: y}, adjacent) do
    positions = for x <- start_x..end_x, do: {x, y}
    Enum.any?(positions, &(&1 in adjacent))
  end

  defp adjacent_positions(start_x, end_x, y) do
    above_positions = for x <- (start_x - 1)..(end_x + 1), do: {x, y - 1}
    below_positions = for x <- (start_x - 1)..(end_x + 1), do: {x, y + 1}

    above_positions ++ below_positions ++ [{start_x - 1, y}, {end_x + 1, y}]
  end
end
