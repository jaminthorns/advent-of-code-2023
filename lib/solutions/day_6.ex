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

  defp win_runs_count(%{time: time, record: record}) do
    # Find the hold times required to beat the record (there are always 2), beat
    # the record by holding 1 ms more/less, and round backwards to the nearest
    # millisecond.
    first_win_hold_time = time |> hold_time(record, 1) |> Kernel.+(1) |> floor()
    last_win_hold_time = time |> hold_time(record, -1) |> Kernel.+(-1) |> ceil()

    last_win_hold_time - first_win_hold_time + 1
  end

  # The distance our boat travels can be written as the equation:
  #
  #   distance = hold_time * (race_time - hold_time)
  #
  # Which can be rewritten into quadratic form like this:
  #
  #   distance = hold_time * (race_time - hold_time)
  #   distance = -hold_time^2 + race_time * hold_time
  #   0 = -hold_time^2 + race_time * hold_time - distance
  #
  # Remember the quadratic formula. For any equation:
  #
  #   0 = ax^2 + bx + c
  #
  # We can solve for x with:
  #
  #   x = (-b +- sqrt(b^2 - 4ac)) / 2a
  #
  # For our equation:
  #
  #   a = -1
  #   b = race_time
  #   c = -distance
  #
  # So the solution to our equation is:
  #
  #   hold_time = (-race_time +- sqrt(race_time^2 - 4 * distance)) / -2
  defp hold_time(race_time, distance, sign) do
    (-race_time + sign * (race_time ** 2 - 4 * distance) ** 0.5) / -2
  end
end
