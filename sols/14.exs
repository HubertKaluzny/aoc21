defmodule Polymerization do

  def parse_recipe(line) do
    [input, results] = String.split(line, ~r/\s->\s/, trim: true)
    [a, b] = String.graphemes(input)
    {a, b, results}
  end

  def get_insertions(_, _, []), do: nil

  def get_insertions(a, b, [{x, y, res} | tail]) do
    if a == x and b == y do
      res
    else
      get_insertions(a, b, tail)
    end
  end

  def compute_step_tail(input, recipes) do
    compute_step_tail(input, recipes, [])
  end

  def compute_step_tail([], _, acc), do: acc
  def compute_step_tail([single], _, acc), do: acc ++ [single]

  def compute_step_tail([a, b | tail], recipes, acc) do
    compute_step_tail([b | tail], recipes, acc ++ [a, get_insertions(a, b, recipes)])
  end

  def part1(input, _, 0), do: input

  def part1(input, recipes, steps) do
    result = compute_step_tail(input, recipes)
    part1(result, recipes, steps - 1)
  end

  def part2_bin([a, b], recipes, steps, mem) do
    cond do
      Map.has_key?(mem, {a, b, steps}) # we've calculated this before
        ->  values = Map.get(mem, {a, b, steps})
            {values, mem}
      steps <= 5                     # calculate and store the result
        ->  sol = part1([a, b], recipes, steps)
            res_count = Enum.reduce(sol, %{}, fn c, map -> Map.put(map, c, (map[c] || 0) + 1 ) end)
            new_mem = Map.put(mem, {a, b, steps}, res_count)
            {res_count, new_mem}
      true                             # go next level down
        ->  insertion = get_insertions(a, b, recipes)
            {left_res, left_mem} = part2_bin([a, insertion], recipes, steps - 1, mem)
            combined_mem = Map.merge(mem, left_mem)
            {right_res, right_mem} = part2_bin([insertion, b], recipes, steps - 1, combined_mem)

            combined_res = Map.merge(left_res, right_res, fn _k, v1, v2 -> v1 + v2 end)

            # so we don't count the insertion twice
            combined_res_fixed = Map.put(combined_res, insertion, combined_res[insertion] - 1)

            mem1 = Map.put(right_mem, {a, insertion, steps - 1}, left_res)
            mem2 = Map.put(mem1, {insertion, b, steps - 1}, right_res)

            {combined_res_fixed, mem2}
    end
  end

  def part2([], _, _, mem, res), do: {res, mem}

  def part2([_], _, _, mem, res), do: {res, mem}

  def part2([a, b | tail], recipes, steps, mem, res) do
    {cur_res, new_mem} = part2_bin([a, b], recipes, steps, mem)
    new_res = Map.merge(res, cur_res, fn _k, v1, v2 -> v1 + v2 end)
    part2([b | tail], recipes, steps, new_mem, new_res)
  end


end

{:ok, contents} = File.read('input.txt')

[input_string, recipes_input] = contents |> String.split(~r/\s\n/, trim: true)
recipes = recipes_input |> String.split(~r/\n/, trim: true) |> Enum.map(&Polymerization.parse_recipe/1)
input = String.graphemes(input_string)

p1 = Polymerization.part1(input, recipes, 10)
p1_character_count = Enum.reduce(p1, %{}, fn c, map -> Map.put(map, c, (map[c] || 0) + 1 ) end)
max = Enum.max(Map.values(p1_character_count))
min = Enum.min(Map.values(p1_character_count))
IO.puts(max)
IO.puts(min)
IO.puts(max - min)

# sometimes 1 too high or 1 too low ?
{p2_res, _} = Polymerization.part2(Polymerization.part1(input, recipes, 1), recipes, 39, %{}, %{})
p2_max = Enum.max(Map.values(p2_res))
p2_min = Enum.min(Map.values(p2_res))
IO.puts(p2_max)
IO.puts(p2_min)
IO.puts(p2_max - p2_min)
