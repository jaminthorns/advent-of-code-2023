defmodule Solutions.Day8 do
  @behaviour Solution

  @test_input_1 """
  RL

  AAA = (BBB, CCC)
  BBB = (DDD, EEE)
  CCC = (ZZZ, GGG)
  DDD = (DDD, DDD)
  EEE = (EEE, EEE)
  GGG = (GGG, GGG)
  ZZZ = (ZZZ, ZZZ)
  """

  @test_input_2 """
  LLR

  AAA = (BBB, BBB)
  BBB = (AAA, ZZZ)
  ZZZ = (ZZZ, ZZZ)
  """

  @doc """
  iex> solve_part_1(#{inspect(@test_input_1)})
  2

  iex> solve_part_1(#{inspect(@test_input_2)})
  6
  """
  def solve_part_1(input) do
    input
    |> document()
    |> navigate_steps(["AAA"], ["ZZZ"])
  end

  @test_input_3 """
  LR

  11A = (11B, XXX)
  11B = (XXX, 11Z)
  11Z = (11B, XXX)
  22A = (22B, XXX)
  22B = (22C, 22C)
  22C = (22Z, 22Z)
  22Z = (22B, 22B)
  XXX = (XXX, XXX)
  """

  @doc """
  iex> solve_part_2(#{inspect(@test_input_3)})
  6
  """
  def solve_part_2(input) do
    %{network: network} = document = document(input)

    nodes = Map.keys(network)
    starts = Enum.filter(nodes, &String.ends_with?(&1, "A"))
    ends = Enum.filter(nodes, &String.ends_with?(&1, "Z"))

    navigate_steps(document, starts, ends)
  end

  defp document(input) do
    [instructions, network] = String.split(input, "\n\n", trim: true)
    instructions = String.graphemes(instructions)

    network =
      network
      |> String.split("\n", trim: true)
      |> Map.new(fn line ->
        [key, nodes] = String.split(line, " = ")

        [left, right] =
          nodes
          |> String.trim_leading("(")
          |> String.trim_trailing(")")
          |> String.split(", ")

        {key, {left, right}}
      end)

    %{instructions: instructions, network: network}
  end

  defp navigate_steps(document, starts, ends) do
    starts
    |> Enum.map(&step_count(document, &1, ends))
    |> Util.lcm()
  end

  defp step_count(%{instructions: instructions, network: network}, start, ends) do
    instructions
    |> Stream.cycle()
    |> Stream.scan(start, &step(network, &2, &1))
    |> Enum.find_index(&(&1 in ends))
    |> Kernel.+(1)
  end

  defp step(network, current, direction) do
    case {direction, Map.get(network, current)} do
      {"L", {left, _}} -> left
      {"R", {_, right}} -> right
    end
  end
end
