import Config

config :app,
  app_key: System.get_env("APP_KEY"),
  access_key: System.get_env("ACCESS_KEY"),
  secret_key: System.get_env("SECRET_KEY"),
  user_account: System.get_env("USER_ACCOUNT"),
  user_password: System.get_env("USER_PASSWORD"),
  api_host: System.get_env("API_HOST"),
  api_version: "v1"
