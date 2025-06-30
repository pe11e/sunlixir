defmodule Crypto.Rsa do
  @spec encrypt(String.t()) :: {:ok, binary()}
  def encrypt(value) do
    with {:ok, rsa_public_key} <- load_rsa_key(),
         {:ok, cipher_text} <- ExPublicKey.encrypt_public(value, rsa_public_key) do
      {:ok, cipher_text}
    else
      _ -> raise {:error, "unable to encrypt"}
    end
  end

  @spec load_rsa_key() :: {:ok, struct()}
  defp load_rsa_key() do
    with {:ok, pem_string} <- get_public_key(),
         {:ok, public_key} <- ExPublicKey.loads(pem_string) do
      {:ok, public_key}
    else
      _ -> raise {:error, "unable to load rsa key"}
    end
  end

  @spec get_public_key() :: {:ok, binary()} | {:error, String.t()}
  defp get_public_key() do
    case File.exists?(get_file_path()) do
      true ->
        File.read(get_file_path())

      false ->
        create_public_key_pem()
    end
  end

  @spec create_public_key_pem() :: {:ok, binary()} | {:error, String.t()}
  defp create_public_key_pem() do
    with :ok <- File.write(get_file_path(), create_key()),
         pem_key <- File.read(get_file_path()) do
      pem_key
    else
      {:error, _} -> raise {:error, "unable to get pem key"}
    end
  end

  @spec create_key() :: binary()
  defp create_key() do
    secret_key =
      Application.get_env(:app, :secret_key)
      |> String.replace("-", "+")
      |> String.replace("_", "/")

    raw_key = [
      "-----BEGIN PUBLIC KEY-----\n",
      secret_key <> "\n",
      "-----END PUBLIC KEY-----\n"
    ]

    raw_key |> :binary.list_to_bin()
  end

  @spec get_file_path() :: String.t()
  defp get_file_path do
    List.to_string([:code.priv_dir(:app), "/public_key.pem"])
  end
end
