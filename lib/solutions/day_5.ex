defmodule Solutions.Day5 do
  @behaviour Solution

  @test_input """
  seeds: 79 14 55 13

  seed-to-soil map:
  50 98 2
  52 50 48

  soil-to-fertilizer map:
  0 15 37
  37 52 2
  39 0 15

  fertilizer-to-water map:
  49 53 8
  0 11 42
  42 0 7
  57 7 4

  water-to-light map:
  88 18 7
  18 25 70

  light-to-temperature map:
  45 77 23
  81 45 19
  68 64 13

  temperature-to-humidity map:
  0 69 1
  1 0 69

  humidity-to-location map:
  60 56 37
  56 93 4
  """

  @doc """
  iex> solve_part_1(#{inspect(@test_input)})
  35
  """
  def solve_part_1(input) do
    %{seeds: seeds, categories: categories} = almanac(input)

    seeds
    |> Enum.map(&(&1..&1))
    |> Enum.flat_map(&convert(&1, categories, "seed", "location"))
    |> Enum.map(& &1.first)
    |> Enum.min()
  end

  @doc """
  iex> solve_part_2(#{inspect(@test_input)})
  46
  """
  def solve_part_2(input) do
    %{seeds: seeds, categories: categories} = almanac(input)

    seeds
    |> Enum.chunk_every(2)
    |> Enum.map(fn [start, length] -> start..(start + length - 1) end)
    |> Enum.flat_map(&convert(&1, categories, "seed", "location"))
    |> Enum.map(& &1.first)
    |> Enum.min()
  end

  defp almanac(input) do
    ["seeds: " <> seeds | categories] = String.split(input, "\n\n")
    seeds = seeds |> String.split() |> Enum.map(&String.to_integer/1)

    categories =
      Enum.map(categories, fn map ->
        [title, maps] = String.split(map, " map:\n")
        [source, destination] = String.split(title, "-to-")
        maps = maps |> String.split("\n", trim: true) |> Enum.map(&maps/1)

        %{source: source, destination: destination, maps: maps}
      end)

    %{seeds: seeds, categories: categories}
  end

  defp maps(line) do
    [dest_start, src_start, length] =
      line
      |> String.split()
      |> Enum.map(&String.to_integer/1)

    %{
      source: src_start..(src_start + length - 1),
      destination: dest_start..(dest_start + length - 1)
    }
  end

  defp convert(range, _categories, final, final), do: [range]

  defp convert(range, categories, source, final) do
    category = Enum.find(categories, &(&1.source == source))

    range
    |> map_range(category.maps)
    |> Enum.flat_map(&convert(&1, categories, category.destination, final))
  end

  defp map_range(range, maps) do
    maps = Enum.reject(maps, &Range.disjoint?(&1.source, range))

    mapped =
      Enum.flat_map(maps, fn map ->
        shift = map.destination.first - map.source.first

        range
        |> intersection(map.source)
        |> Enum.map(&Range.shift(&1, shift))
      end)

    unmapped =
      Enum.reduce_while(maps, [range], fn map, ranges ->
        {ranges, [last]} = Enum.split(ranges, -1)

        case difference(last, map.source) do
          [] -> {:halt, ranges}
          unmapped -> {:cont, ranges ++ unmapped}
        end
      end)

    mapped ++ unmapped
  end

  defp intersection(range_1, range_2) do
    range = max(range_1.first, range_2.first)..min(range_1.last, range_2.last)//1

    Enum.reject([range], &Enum.empty?/1)
  end

  defp difference(range_1, range_2) do
    range_a = range_1.first..min(range_1.last, range_2.first - 1)//1
    range_b = max(range_1.first, range_2.last + 1)..range_1.last//1

    Enum.reject([range_a, range_b], &Enum.empty?/1)
  end
end
