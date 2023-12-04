defmodule AllDaysTest do
  use ExUnit.Case

  behaviours = fn module ->
    :attributes
    |> module.__info__()
    |> Keyword.get(:behaviour, [])
  end

  day = fn module ->
    module
    |> Module.split()
    |> List.last()
    |> String.replace_prefix("Day", "")
  end

  Solution
  |> Application.get_application()
  |> Application.spec(:modules)
  |> Enum.filter(&(Solution in behaviours.(&1)))
  |> Enum.map(fn module ->
    doctest module, import: true, tags: [String.to_atom("day_#{day.(module)}")]
  end)
end
