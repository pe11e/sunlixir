defmodule Api.Base do
  defmacro __using__(opts) do
    quote location: :keep, bind_quoted: [opts: opts] do
      use HTTPoison.Base

      @api_host Application.compile_env!(:app, :api_host)
      @api_version Application.compile_env!(:app, :api_version)
      @access_key Application.compile_env!(:app, :access_key)
      @app_key Application.compile_env!(:app, :app_key)

      service_url = Keyword.get(opts, :service_url)

      def post?(url, body) do
        random_key = Utils.generate_random_key()

        extendedBody =
          Map.merge(
            %{
              appkey: @app_key,
              api_key_param: %{
                nonce: Utils.generate_random_number(32),
                timestamp: :os.system_time(:milli_seconds)
              },
              version_tag: "1",
              lang: "_en_US",
              sys_code: 200
            },
            body
          )

        encrypted_body = Crypto.Aes.encode(extendedBody, random_key)

        headers = [
          {:random_key, random_key}
        ]

        response = post(url, encrypted_body, headers)

        Api.Base.parse_post(response, random_key)
      end

      def post?(url, body, headers) do
        random_key = Utils.generate_random_key()

        extendedBody =
          Map.merge(
            %{
              appkey: @app_key,
              api_key_param: %{
                nonce: Utils.generate_random_number(32),
                timestamp: :os.system_time(:milli_seconds)
              },
              lang: "_en_US",
              sys_code: 200
            },
            body
          )

        encrypted_body = Crypto.Aes.encode(extendedBody, random_key)

        headers = [
          {:random_key, random_key}
          | headers
        ]

        response = post(url, encrypted_body, headers)

        Api.Base.parse_post(response, random_key)
      end

      def process_request_url(endpoint) do
        URI.parse("#{unquote(@api_host)}")
        |> URI.merge("/" <> unquote(@api_version))
        |> Map.update!(:path, &(&1 <> "/" <> unquote(service_url)))
        |> Map.update!(:path, &(&1 <> "/" <> endpoint))
        |> to_string()
      end

      def process_request_headers(headers) do
        [
          {"x-access-key", unquote(@access_key)},
          {"sys_code", "200"},
          {"content-type", "text/plain"}
          | extend_headers(headers)
        ]
      end

      defp extend_headers(headers) do
        Enum.map(headers, fn map ->
          case map do
            {:limit_object, limit_object} ->
              {:ok, user_id} = Map.fetch(limit_object, :user_id)
              {:ok, x_limit_object} = Crypto.Rsa.encrypt(user_id)
              {"x-limit-obj", x_limit_object}

            {:random_key, random_key} ->
              {:ok, x_random_key} = Crypto.Rsa.encrypt(random_key)
              {"x-random-secret-key", x_random_key}
          end
        end)
      end
    end
  end

  def parse_post({:ok, %HTTPoison.Response{status_code: code, body: body}}, random_key)
      when code in 200..299 do
    Crypto.Aes.decode(body, random_key) |> get_result_data()
  end

  def parse_post({:error, %HTTPoison.Response{body: body}}, random_key) do
    IO.inspect(body)
    error = Crypto.Aes.decode(body, random_key) |> get_result_data()
    {:error, error}
  end

  def parse_post({:error, %HTTPoison.Error{reason: reason}}, _) do
    IO.inspect("reason #{reason}")
    {:error, reason}
  end

  def get_result_data({:ok, decoded_response}) do
    {:ok, result_data} = Map.fetch(decoded_response, "result_data")
    {:ok, result_data}
  end
end
