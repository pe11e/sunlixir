defmodule Utils do
  @spec generate_random_key() :: String.t()
  def generate_random_key() do
    generate_random_number(13)
    |> String.split(" ")
    |> List.insert_at(0, "web")
    |> Enum.join("")
    |> String.trim()
  end

  @spec generate_random_number(non_neg_integer()) :: binary()
  def generate_random_number(number) do
    :crypto.strong_rand_bytes(32)
    |> Base.encode16()
    |> String.downcase()
    |> String.slice(0, number)
  end
end
