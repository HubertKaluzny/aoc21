defmodule Submarine do

  def parse_line(line) do
    [instr, num] = String.split(line, " ")

    parsed = case instr do
      "forward" -> :forward
      "down"    -> :down
      "up"      -> :up
    end

    {parsed, String.to_integer(num)}
  end

  def compute_pos([], state) do
    state
  end

  # part 1
  def compute_pos([{instr, num} | tail], {horiz, depth}) do

    case instr do
      :forward -> compute_pos(tail, {horiz + num, depth})
      :down    -> compute_pos(tail, {horiz, depth + num})
      :up      -> compute_pos(tail, {horiz, depth - num})
    end
  end


  def compute_pos_w_aim([], state) do
    state
  end

  # part 2
  def compute_pos_w_aim([{instr, num} | tail], {horiz, depth, aim}) do

    case instr do
      :forward -> compute_pos_w_aim(tail, {horiz + num, depth + (num * aim), aim})
      :down    -> compute_pos_w_aim(tail, {horiz, depth, aim + num})
      :up      -> compute_pos_w_aim(tail, {horiz, depth, aim - num})
    end
  end

end

{:ok, contents} = File.read('input.txt')
instructions = contents |> String.split("\n", trim: true) |> Enum.map(&Submarine.parse_line/1)
{horiz, depth, _} = Submarine.compute_pos_w_aim(instructions, {0, 0, 0})
IO.puts(horiz)
IO.puts(depth)
IO.puts(horiz * depth)
