defmodule Diagnostics do

  def parse_line(line) do
    Enum.map(String.codepoints(line), fn x -> String.to_integer(x) end)
  end

  def add_cols([], []) do
    []
  end

  def add_cols([a | a_tail], [b | b_tail]) do
    [(a + b) | add_cols(a_tail, b_tail)]
  end

  def sum_rows([], sum) do
    sum
  end

  def sum_rows([head | tail], sum) do
    sum_rows(tail, add_cols(head, sum))
  end

  def int_list_to_string(input) do
    Enum.join(Enum.map(input, fn x -> Integer.to_string(x) end), "")
  end

  def to_gamma(codes_sum, input_size) do
    Enum.map(codes_sum, fn x -> if x > input_size - x, do: 1, else: 0 end)
  end

  def inverse(input) do
    Enum.map(input, fn x -> if x == 0, do: 1, else: 0 end)
  end

  def power_consumption(gamma_bits) do
    epsilon_bits = inverse(gamma_bits)

    {gamma, _} = Integer.parse(int_list_to_string(gamma_bits), 2)
    {epsilon, _} = Integer.parse(int_list_to_string(epsilon_bits), 2)

    gamma * epsilon
  end

  def filter(input, s_bit, target) do
    Enum.filter(input, fn x -> Enum.at(x, s_bit) == target end)
  end

  def oxy_rating([_], _) do
    []
  end

  def oxy_rating(input, s_bit) do
    sum_bits = sum_rows(input, List.duplicate(0, length(List.first(input))))
    classifier = Enum.at(sum_bits, s_bit)
    if classifier >= length(input) - classifier do
      [1 | oxy_rating(filter(input, s_bit, 1), s_bit + 1)]
    else
      [0 | oxy_rating(filter(input, s_bit, 0), s_bit + 1)]
    end
  end

  def co2_rating([res], _) do
    res
  end

  def co2_rating(input, s_bit) do
    sum_bits = sum_rows(input, List.duplicate(0, length(List.first(input))))
    classifier = Enum.at(sum_bits, s_bit)
    if classifier >= length(input) - classifier do
      co2_rating(filter(input, s_bit, 0), s_bit + 1)
    else
      co2_rating(filter(input, s_bit, 1), s_bit + 1)
    end
  end

  def life_support_rating(input) do
    oxy_bits = oxy_rating(input, 0)
    co2_bits = co2_rating(input, 0)

    {oxy, _} = Integer.parse(int_list_to_string(oxy_bits), 2)
    {co2, _} = Integer.parse(int_list_to_string(co2_bits), 2)

    oxy * co2
  end

end

{:ok, contents} = File.read('input.txt')
input = contents |> String.split("\n", trim: true) |> Enum.map(&Diagnostics.parse_line/1)
IO.puts(Diagnostics.power_consumption(gamma))
IO.puts(Diagnostics.life_support_rating(input))
