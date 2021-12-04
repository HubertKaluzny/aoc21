defmodule Bingo do

  def parse_lines([bing_nums | tail]) do
    parsed_bing_nums = String.replace(bing_nums, "\n", "") |> String.split(",", trim: true) |> Enum.map(&String.to_integer/1)
    {parsed_bing_nums, Enum.map(tail, &parse_board/1)}
  end

  # should return a list of lists
  def parse_board(board) do
    lines = String.split(board, "\n", trim: true)
    lines = Enum.map(lines, fn line -> String.split(line, ~r/\s+/, trim: true) end)
    Enum.map(lines, fn line -> Enum.map(line, &String.to_integer/1) end)
  end

  # mark a winner with a -1 (although we lose information on what it was)
  def mark_board(num, board) do
    Enum.map(board, fn row -> Enum.map(row, fn x -> if num == x, do: -1, else: x end) end)
  end

  def transpose([[] | _]), do: []

  def transpose(m) do
    [Enum.map(m, &hd/1) | transpose(Enum.map(m, &tl/1))]
  end

  def has_won(board) do
    row_sums = Enum.map(board, &Enum.sum/1)
    col_sums = Enum.map(transpose(board), &Enum.sum/1)
    row_win  = length(Enum.filter(row_sums, fn x -> x == -(length(row_sums)) end)) > 0
    col_win  = length(Enum.filter(col_sums, fn x -> x == -(length(col_sums)) end)) > 0
    row_win || col_win
  end

  # in case no boards win
  def play_until_win([], b), do: {-1, b}

  # part 1
  def play_until_win([head | tail], boards) do
    marked_boards = Enum.map(boards, fn b -> mark_board(head, b) end)
    has_any_wins = length(Enum.filter(marked_boards, fn b -> has_won(b) end)) > 0
    if has_any_wins do
      {head, marked_boards}
    else
      play_until_win(tail, marked_boards)
    end
  end

  # part 2
  def play_until_last_win([], b), do: {-1, b}

  def play_until_last_win([head | tail], boards) do
    still_not_winning_boards = Enum.filter(boards, fn b -> not has_won(b) end)
    marked_boards = Enum.map(still_not_winning_boards, fn b -> mark_board(head, b) end)

    if length(marked_boards) == 1 && has_won(List.first(marked_boards)) do
      {head, List.first(marked_boards)}
    else
      play_until_last_win(tail, marked_boards)
    end

  end

  def sum_unmarked_board(board) do
    row_sums = Enum.map(board, fn line -> Enum.sum(Enum.filter(line, fn x -> x != -1 end)) end)
    Enum.sum(row_sums)
  end

end

{:ok, contents} = File.read('input.txt')

{bing_nums, boards} = contents |> String.split(~r/\s\n/, trim: true) |> Bingo.parse_lines()

# part 1
IO.puts("part 1")
{last_num, marked_boards} = Bingo.play_until_win(bing_nums, boards)
winning_boards = Enum.filter(marked_boards, &Bingo.has_won/1)
winning_board_scores = Enum.map(winning_boards, fn b -> last_num * Bingo.sum_unmarked_board(b) end)
IO.puts(IO.inspect(winning_board_scores))

# part 2
IO.puts("part 2")
{last_num, last_board} = Bingo.play_until_last_win(bing_nums, boards)
last_board_score = last_num * Bingo.sum_unmarked_board(last_board)
IO.puts(last_board_score)
