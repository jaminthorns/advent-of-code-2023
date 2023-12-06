defmodule Solutions.Day6 do
  @behaviour Solution

  @test_input """
  Time:      7  15   30
  Distance:  9  40  200
  """

  @doc """
  iex> solve_part_1(#{inspect(@test_input)})
  288
  """
  def solve_part_1(input) do
    input
    |> races(multiple: true)
    |> Enum.map(&win_runs_count/1)
    |> Enum.product()
  end

  @doc """
  iex> solve_part_2(#{inspect(@test_input)})
  71503
  """
  def solve_part_2(input) do
    input
    |> races(multiple: false)
    |> Enum.map(&win_runs_count/1)
    |> Enum.product()
  end

  defp races(input, opts) do
    ["Time:" <> times, "Distance:" <> records] = String.split(input, "\n", trim: true)

    {times, records} =
      if Keyword.get(opts, :multiple),
        do: {multiple(times), multiple(records)},
        else: {single(times), single(records)}

    times
    |> Enum.zip(records)
    |> Enum.map(fn {time, record} -> %{time: time, record: record} end)
  end

  defp multiple(line), do: line |> String.split() |> Enum.map(&String.to_integer/1)
  defp single(line), do: line |> String.replace(" ", "") |> String.to_integer() |> List.wrap()

  defp win_runs_count(race) do
    race
    |> runs()
    |> Enum.filter(&breaks_record?(&1, race.record))
    |> Enum.count()
  end

  defp runs(%{time: time}) do
    Enum.map(0..time, &%{hold: &1, distance: &1 * (time - &1)})
  end

  defp breaks_record?(%{distance: distance}, record), do: distance > record
end
