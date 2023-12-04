defmodule Solutions.Day1 do
  @behaviour Solution

  @test_input_1 """
  1abc2
  pqr3stu8vwx
  a1b2c3d4e5f
  treb7uchet
  """

  @doc """
  iex> solve_part_1(#{inspect(@test_input_1)})
  142
  """
  def solve_part_1(input) do
    calibrate(input, &extract_digit/1)
  end

  @test_input_2 """
  two1nine
  eightwothree
  abcone2threexyz
  xtwone3four
  4nineeightseven2
  zoneight234
  7pqrstsixteen
  """

  @doc """
  iex> solve_part_2(#{inspect(@test_input_2)})
  281
  """
  def solve_part_2(input) do
    calibrate(input, &extract_digit_or_word/1)
  end

  defp calibrate(input, extract) do
    input
    |> String.split()
    |> Enum.map(&digits(&1, extract))
    |> Enum.map(&Integer.undigits([List.first(&1), List.last(&1)]))
    |> Enum.sum()
  end

  defp digits(line, extract) do
    Stream.iterate({[], line}, fn {digits, line} ->
      case extract.(line) do
        {nil, rest} -> {digits, rest}
        {digit, rest} -> {digits ++ [digit], rest}
      end
    end)
    |> Enum.find(fn {_digits, line} -> line == "" end)
    |> elem(0)
  end

  def extract_digit("1" <> rest), do: {1, rest}
  def extract_digit("2" <> rest), do: {2, rest}
  def extract_digit("3" <> rest), do: {3, rest}
  def extract_digit("4" <> rest), do: {4, rest}
  def extract_digit("5" <> rest), do: {5, rest}
  def extract_digit("6" <> rest), do: {6, rest}
  def extract_digit("7" <> rest), do: {7, rest}
  def extract_digit("8" <> rest), do: {8, rest}
  def extract_digit("9" <> rest), do: {9, rest}
  def extract_digit(<<_first>> <> rest), do: {nil, rest}

  def extract_word("one" <> rest), do: {1, rest}
  def extract_word("two" <> rest), do: {2, rest}
  def extract_word("three" <> rest), do: {3, rest}
  def extract_word("four" <> rest), do: {4, rest}
  def extract_word("five" <> rest), do: {5, rest}
  def extract_word("six" <> rest), do: {6, rest}
  def extract_word("seven" <> rest), do: {7, rest}
  def extract_word("eight" <> rest), do: {8, rest}
  def extract_word("nine" <> rest), do: {9, rest}
  def extract_word(<<_first>> <> rest), do: {nil, rest}

  def extract_digit_or_word(line) do
    with {nil, _rest} <- extract_digit(line), do: extract_word(line)
  end
end
