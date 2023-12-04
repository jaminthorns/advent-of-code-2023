defmodule Day4 do
  @behaviour Solution

  @test_input """
  Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
  Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
  Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
  Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
  Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
  Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
  """

  @doc """
  iex> solve_part_1(#{inspect(@test_input)})
  13
  """
  def solve_part_1(input) do
    input
    |> cards()
    |> Enum.map(&wins/1)
    |> Enum.filter(&(&1 > 0))
    |> Enum.map(&Integer.pow(2, &1 - 1))
    |> Enum.sum()
  end

  @doc """
  iex> solve_part_2(#{inspect(@test_input)})
  30
  """
  def solve_part_2(input) do
    input
    |> cards()
    |> card_counts()
    |> Map.values()
    |> Enum.sum()
  end

  defp cards(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.replace(&1, ~r/^Card +/, ""))
    |> Enum.map(&String.split(&1, ": "))
    |> Enum.map(fn [id, numbers] ->
      [winning, mine] = String.split(numbers, " | ")

      %{
        id: String.to_integer(id),
        winning: numbers(winning),
        mine: numbers(mine)
      }
    end)
  end

  defp numbers(string) do
    string
    |> String.split()
    |> Enum.map(&String.to_integer/1)
  end

  defp wins(%{winning: winning, mine: mine}) do
    mine
    |> Enum.filter(&(&1 in winning))
    |> length()
  end

  defp card_counts(cards) do
    counts = Map.new(cards, &{&1.id, 1})

    Enum.reduce(cards, counts, fn %{id: id} = card, counts ->
      next = id + 1
      last = next + wins(card) - 1
      count = Map.get(counts, id)

      Enum.reduce(next..last//1, counts, fn id, counts ->
        Map.update!(counts, id, &(&1 + count))
      end)
    end)
  end
end
