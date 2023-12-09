defmodule Solutions.Day9 do
  @behaviour Solution

  @test_input """
  0 3 6 9 12 15
  1 3 6 10 15 21
  10 13 16 21 30 45
  """

  @doc """
  iex> solve_part_1(#{inspect(@test_input)})
  114
  """
  def solve_part_1(input) do
    input
    |> sequences()
    |> Enum.map(&all_differences([&1]))
    |> Enum.map(&predict_forward/1)
    |> Enum.sum()
  end

  @doc """
  iex> solve_part_2(#{inspect(@test_input)})
  2
  """
  def solve_part_2(input) do
    input
    |> sequences()
    |> Enum.map(&all_differences([&1]))
    |> Enum.map(&predict_backward/1)
    |> Enum.sum()
  end

  defp sequences(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn sequence ->
      sequence
      |> String.split()
      |> Enum.map(&String.to_integer/1)
    end)
  end

  defp all_differences([current | _] = sequences) do
    differences = differences(current)
    sequences = [differences | sequences]

    if Enum.all?(differences, &(&1 == 0)) do
      sequences
    else
      all_differences(sequences)
    end
  end

  defp differences(sequence) do
    sequence
    |> Enum.drop(1)
    |> Enum.zip(sequence)
    |> Enum.map(fn {next, prev} -> next - prev end)
  end

  defp predict_forward(sequences) do
    Enum.reduce(sequences, 0, &(List.last(&1) + &2))
  end

  defp predict_backward(sequences) do
    Enum.reduce(sequences, 0, &(List.first(&1) - &2))
  end
end
