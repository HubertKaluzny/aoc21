defmodule HowMany do

  # part 1 of problem
  def increasing([head | rest]) do
    increasing(rest, head)
  end

  def increasing([head | rest], last) do
    if head > last do
      1 + increasing(rest, head)
    else
      increasing(rest, head)
    end
  end

  def increasing([], _) do
    0
  end

  # part 2
  # Approach same as problem was described
  # Sum all the lists and run our previous increasing
  # function on it.
  def avg_increasing_simple(input) do
    [_, head1 | tail] = input
    sliding_window = Enum.map(
      Enum.zip(input, Enum.zip([head1 | tail], tail)),
      fn {a, {b, c}} -> a + b + c end
    )

    increasing(sliding_window)
  end

  # 2 values always overlap so we just need to figure out
  # whether the one just out of the sliding window is
  # smaller than the new one

  # base case first (stops at 4 elements left in list)
  def avg_increasing_better([gone, _, _, c]) do
    if gone < c do
      1
    else
      0
    end
  end

  def avg_increasing_better([gone, a, b, c | tail]) do
    next = avg_increasing_better([a, b, c | tail])
    if gone < c do
      1 + next
    else
      next
    end
  end

end

{:ok, contents} = File.read('input.txt')
input = contents |> String.split("\n", trim: true) |> Enum.map(&String.to_integer/1)
IO.puts(HowMany.increasing(input))
IO.puts(HowMany.avg_increasing_simple(input))
IO.puts(HowMany.avg_increasing_better(input))
