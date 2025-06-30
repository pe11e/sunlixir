defmodule Api.Endpoints.PowerStation do
  use Api.Base, service_url: "powerStationService"

  def get_ps_detail_with_ps_type(credentials) do
    headers = [
      {:limit_object, credentials}
    ]

    case post?("getPsDetailWithPsType", %{}, headers) do
      {:ok, response} ->
        response

      {:error, _} ->
        IO.puts("No power")
    end
  end

  def get_ps_filter_item_list(credentials) do
    headers = [
      {:limit_object, credentials}
    ]

    case post?("getPsFilterItemList", %{}, headers) do
      {:ok, response} ->
        response

      {:error, _} ->
        IO.puts("No power")
    end
  end

  def get_ps_list_nova(credentials) do
    headers = [
      {:limit_object, credentials}
    ]

    case post?("getPsListNova", %{}, headers) do
      {:ok, response} ->
        {:ok, plant_list} = Map.fetch(response, "pageList")
        plant = hd(plant_list)
        {:ok, plant}

      {:error, _} ->
        IO.puts("No power")
    end
  end

  def get_ps_energy_summary_info(credentials) do
    headers = [
      {:limit_object, credentials}
    ]

    case post?("getPsEnergySummaryInfo", %{}, headers) do
      {:ok, response} ->
        {:ok, response}

      {:error, _} ->
        IO.puts("No summary")
    end
  end

  #   appkey
  # :
  # "B0455FBE7AA0328DB57B59AA729F05D8"
  # date_id
  # :
  # "20240603"
  # date_type
  # :
  # "1"
  # lang
  # :
  # "_en_US"
  # minute_interval
  # :
  # "5"
  # ps_id
  # :
  # 5200216
  # sys_code
  # :
  # 200
  # token
  # :
  # "221591_2e2451f6c9fa4a2c812def497b79073e"
  # version_tag
  # :
  # "1"
  def get_house_hold_storage_ps_report(credentials) do
    headers = [
      {:limit_object, credentials}
    ]

    case(post?("getHouseholdStoragePsReport", %{}, headers)) do
      {:ok, response} ->
        response

      {:error, _} ->
        IO.puts("error household report")
    end
  end
end
