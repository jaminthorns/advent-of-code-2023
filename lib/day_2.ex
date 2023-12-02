defmodule Day2 do
  @behaviour Solution

  @test_input """
  Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
  Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
  Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
  Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
  Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
  """

  @doc """
  iex> solve_part_1(#{inspect(@test_input)})
  8
  """
  def solve_part_1(input) do
    input
    |> games()
    |> Enum.filter(&game_possible?(&1, %{"red" => 12, "green" => 13, "blue" => 14}))
    |> Enum.map(& &1.id)
    |> Enum.sum()
  end

  @doc """
  iex> solve_part_2(#{inspect(@test_input)})
  2286
  """
  def solve_part_2(input) do
    input
    |> games()
    |> Enum.map(&fewest_counts/1)
    |> Enum.map(&Map.values/1)
    |> Enum.map(&power/1)
    |> Enum.sum()
  end

  defp games(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.replace_prefix(&1, "Game ", ""))
    |> Enum.map(&String.split(&1, ": "))
    |> Enum.map(fn [id, subsets] -> %{id: String.to_integer(id), subsets: subsets(subsets)} end)
  end

  defp subsets(subsets) do
    subsets
    |> String.split("; ")
    |> Enum.map(fn subset ->
      subset
      |> String.split(", ")
      |> Enum.map(&String.split(&1, " "))
      |> Map.new(fn [count, color] -> {color, String.to_integer(count)} end)
    end)
  end

  defp game_possible?(%{subsets: subsets}, totals) do
    Enum.all?(subsets, &subset_possible?(&1, totals))
  end

  defp subset_possible?(subset, totals) do
    Enum.all?(totals, fn {color, total} -> Map.get(subset, color, 0) <= total end)
  end

  defp fewest_counts(%{subsets: subsets}) do
    max_merge = fn _key, a, b -> max(a, b) end
    Enum.reduce(subsets, %{"red" => 0, "green" => 0, "blue" => 0}, &Map.merge(&1, &2, max_merge))
  end

  defp power(numbers), do: Enum.reduce(numbers, &(&1 * &2))
end
