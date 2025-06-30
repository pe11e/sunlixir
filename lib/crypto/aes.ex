defmodule Crypto.Aes do
  @block_size 16
  @cipher :aes_ecb

  def encode(data, key) do
    with {:ok, padded_text} <- JSON.encode(data) |> pad_pkcs7(@block_size) do
      :crypto.crypto_one_time(@cipher, key, padded_text, true) |> Base.encode16()
    else
      _ -> raise {:error, "unable to encode aes"}
    end
  end

  @spec decode(binary(), String.t()) :: :error | {atom(), any()}
  def decode(data, key) do
    with {:ok, cipher_text} <- Base.decode16(data) do
      :crypto.crypto_one_time(@cipher, key, cipher_text, false) |> unpad_pkcs7() |> JSON.decode()
    else
      _ -> raise {:error, "unable to decode aes"}
    end
  end

  @spec pad_pkcs7({atom(), bitstring()}, non_neg_integer()) :: {atom(), String.t()}
  defp pad_pkcs7({:ok, message}, block_size) do
    pad = block_size - rem(byte_size(message), block_size)
    {:ok, message <> to_string(List.duplicate(pad, pad))}
  end

  @spec unpad_pkcs7(String.t()) :: binary()
  defp unpad_pkcs7(data) do
    <<pad>> = binary_part(data, byte_size(data), -1)
    binary_part(data, 0, byte_size(data) - pad)
  end
end
