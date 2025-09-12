import Config

config :swoosh, :api_client, Swoosh.ApiClient.Hackney

config :hermes, Hermes.Mailer,
  adapter: Swoosh.Adapters.SMTP,
  relay: System.get_env("SMTP_HOST"),
  username: System.get_env("SMTP_USERNAME"),
  password: System.get_env("SMTP_PASSWORD"),
  ssl: System.get_env("SMTP_SECURE") == "true",
  tls: :always,
  auth: :always,
  port: String.to_integer(System.get_env("SMTP_PORT") || "587")

config :ex_aws,
  region: System.get_env("AWS_REGION") || "us-east-1",
  access_key_id: System.get_env("AWS_ACCESS_KEY_ID") || "test",
  secret_access_key: System.get_env("AWS_SECRET_ACCESS_KEY") || "test",
  sqs: [scheme: System.get_env("AWS_SCHEME") || "http://", host: System.get_env("AWS_HOST") || "localstack", port: String.to_integer(System.get_env("AWS_PORT") || "4566")]

config :logger, level: :info
