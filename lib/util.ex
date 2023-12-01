defmodule Util do
  def permute([]), do: [[]]
  def permute(list), do: for(item <- list, rest <- permute(list -- [item]), do: [item | rest])
end
