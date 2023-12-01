defmodule Day1 do
  @behaviour Solution

  @digits 1..9
  @char_digits Enum.map(@digits, &to_string/1)
  @word_digits ~w(one two three four five six seven eight nine)

  @char_digit_mapping @char_digits |> Enum.zip(@digits) |> Map.new()
  @word_digit_mapping @word_digits |> Enum.zip(@digits) |> Map.new()

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
    calibrate(input, @char_digit_mapping)
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
    calibrate(input, Map.merge(@char_digit_mapping, @word_digit_mapping))
  end

  defp calibrate(input, digit_mapping) do
    input
    |> String.split()
    |> Enum.map(&digits(&1, digit_mapping))
    |> Enum.map(&Integer.undigits([List.first(&1), List.last(&1)]))
    |> Enum.sum()
  end

  defp digits(line, digit_mapping) do
    representations = Map.keys(digit_mapping)

    Stream.iterate({[], line}, fn {digits, line} ->
      case Enum.find(representations, &String.starts_with?(line, &1)) do
        nil ->
          {digits, String.slice(line, 1..-1//1)}

        representation ->
          digits = digits ++ [Map.get(digit_mapping, representation)]
          line = String.replace_prefix(line, representation, "")

          {digits, line}
      end
    end)
    |> Stream.drop_while(fn {_digits, line} -> line != "" end)
    |> Stream.map(fn {digits, _line} -> digits end)
    |> Enum.at(0)
  end
end
