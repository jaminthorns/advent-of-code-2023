defmodule Util do
  def permute([]), do: [[]]
  def permute(list), do: for(item <- list, rest <- permute(list -- [item]), do: [item | rest])

  def gcd(numbers) when is_list(numbers), do: Enum.reduce(numbers, &gcd/2)
  def gcd(a, 0), do: a
  def gcd(0, b), do: b
  def gcd(a, b), do: gcd(b, rem(a, b))

  def lcm(numbers) when is_list(numbers), do: Enum.reduce(numbers, &lcm/2)
  def lcm(0, 0), do: 0
  def lcm(a, b), do: div(a * b, gcd(a, b))

  def same?(list) when is_list(list), do: list |> Enum.uniq() |> length() <= 1
end
