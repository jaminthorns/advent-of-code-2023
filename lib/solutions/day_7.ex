defmodule Solutions.Day7 do
  @behaviour Solution

  @test_input """
  32T3K 765
  T55J5 684
  KK677 28
  KTJJT 220
  QQQJA 483
  """

  @doc """
  iex> solve_part_1(#{inspect(@test_input)})
  6440
  """
  def solve_part_1(input) do
    input
    |> hands()
    |> winnings(wild_jokers: false, label_ranks: ~w(2 3 4 5 6 7 8 9 T J Q K A))
  end

  @doc """
  iex> solve_part_2(#{inspect(@test_input)})
  5905
  """
  def solve_part_2(input) do
    input
    |> hands()
    |> winnings(wild_jokers: true, label_ranks: ~w(J 2 3 4 5 6 7 8 9 T Q K A))
  end

  defp hands(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split/1)
    |> Enum.map(fn [cards, bid] ->
      %{cards: String.graphemes(cards), bid: String.to_integer(bid)}
    end)
  end

  defp winnings(hands, rank_opts) do
    hands
    |> Enum.sort_by(&rank(&1.cards, rank_opts))
    |> Enum.with_index()
    |> Enum.map(fn {%{bid: bid}, index} -> bid * (index + 1) end)
    |> Enum.sum()
  end

  defp rank(cards, opts) do
    wild_jokers = Keyword.get(opts, :wild_jokers)
    label_ranks = Keyword.get(opts, :label_ranks)

    {type_rank(cards, wild_jokers), label_rank(cards, label_ranks)}
  end

  defp type_rank(cards, wild_jokers \\ false) do
    cards = if wild_jokers and "J" in cards, do: best_joker_cards(cards), else: cards

    case cards |> Enum.frequencies() |> Map.values() |> Enum.sort() |> Enum.reverse() do
      [5] -> 6
      [4 | _] -> 5
      [3, 2] -> 4
      [3 | _] -> 3
      [2, 2 | _] -> 2
      [2 | _] -> 1
      _ -> 0
    end
  end

  defp best_joker_cards(cards) do
    {jokers, non_jokers} = Enum.split_with(cards, &(&1 == "J"))
    replacements = if Enum.empty?(non_jokers), do: ["A"], else: non_jokers
    joker_count = length(jokers)

    replacements
    |> Enum.uniq()
    |> Enum.map(&(non_jokers ++ List.duplicate(&1, joker_count)))
    |> Enum.max_by(&type_rank/1)
  end

  def label_rank(cards, label_ranks) do
    Enum.map(cards, fn card -> Enum.find_index(label_ranks, &(&1 == card)) end)
  end
end
