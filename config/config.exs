import Config

config :swoosh, :api_client, Swoosh.ApiClient.Hackney

config :hermes, Hermes.Mailer,
  adapter: Swoosh.Adapters.SMTP,
  relay: System.get_env("SMTP_HOST"),
  username: System.get_env("SMTP_USERNAME"),
  password: System.get_env("SMTP_PASSWORD"),
  ssl: false,
  tls: :always,
  auth: :always,
  port: String.to_integer(System.get_env("SMTP_PORT") || "587")

config :logger, level: :info
