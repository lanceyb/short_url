defmodule ShortUrl.ThirtyFourCal do

  def atoms do
    Enum.into(48..57, Enum.to_list(65..90))
  end

  # number is 0 to 33
  # map 0 - 9, A to Z
  def get_atom(number) do
    case number do
      n when n <= 9 -> n + 48
      n when n > 9 and n <= 33 -> n + 55 
      _ -> raise "out of range"
    end
  end

  def cal(stack) do
    case stack do
      [n | stack] when n < 34 -> [n | stack]
      [n | stack] -> cal([div(n, 34), rem(n, 34) | stack])
    end
  end

  def tranform(number) do
    Enum.map(ShortUrl.ThirtyFourCal.cal([number]), fn x -> ShortUrl.ThirtyFourCal.get_atom(x) end)
  end

  def decode do
  end
end
