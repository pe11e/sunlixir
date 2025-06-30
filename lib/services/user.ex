defmodule Services.User do
  @user_json_path "/user.json"
  @plant_json_path "/plant_information.json"
  def login() do
    case get_file_path(@user_json_path) |> File.read() do
      {:ok, user} ->
        {:ok, result} = JSON.decode(user)
        result

      {:error, _} ->
        case Api.Endpoints.User.login() do
          {:ok, saved_user} ->
            saved_user |> JSON.encode!() |> save(@user_json_path)
        end
    end
  end

  def get_plant_information() do
    case get_file_path(@plant_json_path) |> File.read() do
      {:ok, plant_info} ->
        {:ok, result} = JSON.decode(plant_info)
        result

      {:error, _} ->
        case get_credentials() |> Api.Endpoints.PowerStation.get_ps_list_nova() do
          {:ok, plant_info} ->
            plant_info |> JSON.encode!() |> save(@plant_json_path)
        end
    end
  end

  def get_energy_summary() do
    {:ok, ps_id} = get_plant_information() |> Map.fetch("ps_id")
    credentials = Map.merge(get_credentials(), %{ps_id: ps_id})

    body = %Structs.HouseHoldStorageReport{
      ps_id: ps_id,
      date_type: "1",
      date_id: "20240604",
      minute_interval: "5"
    }

    case Api.Endpoints.PowerStation.get_ps_energy_summary_info(credentials) do
      {:ok, response} ->
        response

      _ ->
        IO.puts("nope")
    end
  end

  @spec get_credentials() :: struct()
  def get_credentials do
    login()
    |> Map.take(["user_id", "token"])
    |> Map.new(fn {k, v} -> {String.to_atom(k), v} end)
    |> then(fn fields -> struct(Structs.Credentials, fields) end)
  end

  @spec save(String.t(), binary()) :: :ok | :error
  defp save(encoded_payload, path) do
    IO.inspect(encoded_payload)
    file_path = get_file_path(path)

    case File.exists?(file_path) do
      true ->
        {:ok, file} = File.open(file_path, [:write])
        IO.binwrite(file, encoded_payload)
        File.close(file)

      false ->
        with :ok <- File.touch(file_path),
             :ok <- File.write(file_path, encoded_payload),
             user <- File.read(file_path) do
          user
        end
    end
  end

  defp get_file_path(path) do
    List.to_string([:code.priv_dir(:app), path])
  end
end
