defmodule Pathing do

  def parse_line(line) do
    [a, b] = String.split(line, "-")
    {a, b}
  end

  def traverse(current_path, paths) do
    choices = Enum.filter(paths, fn {a, b} -> a == List.last(current_path) || b == List.last(current_path) end)

    visited_small_caves = Enum.filter(current_path, fn a -> a =~ ~r/^[^A-Z]*$/ end)

    route_lists = for {a, b} <- choices do
      next_point = if a == List.last(current_path), do: b, else: a

      if Enum.member?(visited_small_caves, next_point) do
        []
      else
        new_path = current_path ++ [next_point]
        if next_point == "end" do
          [new_path]
        else
          traverse(new_path, paths)
         end
      end
    end

    Enum.reduce(route_lists, fn x, acc -> x ++ acc end)

  end

  # part 2

  def _visited_twice([]), do: false

  def _visited_twice([head | tail]) do
    Enum.member?(tail, head) || _visited_twice(tail)
  end

  def traverse2(current_path, paths) do
    cur_point = List.last(current_path)
    choices = Enum.filter(paths, fn {a, b} -> a == cur_point || b == cur_point end)

    visited_small_caves = Enum.filter(current_path, fn a -> a =~ ~r/^[^A-Z]*$/ end)

    route_lists = for {a, b} <- choices do
      next_point = if a == cur_point, do: b, else: a
      new_path = current_path ++ [next_point]
      if Enum.member?(visited_small_caves, next_point) do
        cond do
          next_point == "start"               -> []
          next_point == "end"                 -> []
          _visited_twice(visited_small_caves) -> []
          true                                -> traverse2(new_path, paths)
        end
      else
        if next_point == "end" do
          [new_path]
        else
          traverse2(new_path, paths)
         end
      end
    end

    Enum.reduce(route_lists, fn x, acc -> x ++ acc end)

  end
end

{:ok, contents} = File.read('input.txt')

paths = contents |> String.split(~r/\n/, trim: true) |> Enum.map(&Pathing.parse_line/1)
start_paths = Enum.filter(paths, fn {a, b} -> a == "start" or b == "start" end)

all_routes = Enum.reduce(for {a, b} <- start_paths do

  start_path = if a == "start", do: [a, b], else: [b, a]
  Pathing.traverse2(start_path, paths)

end, fn x, acc -> x ++ acc end)

IO.puts(length(all_routes))
