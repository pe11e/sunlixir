defmodule Api.Endpoints.User do
  use Api.Base, service_url: "userService"

  def login() do
    case post?("login", login_payload()) do
      {:ok, response} ->
        {:ok, response}

      {:error, _} ->
        IO.puts("sad panda")
    end
  end

  def query_personal_unit_list(credentials) do
    case post?("queryPersonalUnitList", credentials) do
      {:ok, response} -> response
      {:error, _} -> IO.puts(~c"noo")
    end
  end

  def get_user_unead_red_point_count(credentials) do
    headers = [
      {:limit_object, credentials}
    ]

    case post?("getUserUnReadRedPointCount", credentials, headers) do
      {:ok, response} -> response
      {:error, _} -> IO.puts("noo")
    end
  end

  def get_ps_user(credentials) do
    headers = [
      {:limit_object, credentials}
    ]

    case post?("getPsUser", credentials, headers) do
      {:ok, response} -> response
      {:error, _} -> IO.puts("noo")
    end
  end

  defp login_payload() do
    %{
      user_account: Application.get_env(:app, :user_account),
      user_password: Application.get_env(:app, :user_password)
    }
  end
end
