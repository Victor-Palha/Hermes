defmodule Hermes.Email.Notify do
  @moduledoc """
  A module to handle email notifications.
  Supports single or multiple recipients, with concurrent delivery.
  """

  # alias Hermes.Mailer
  # import Swoosh.Email
  require Logger

  def call(%{"to" => recipients, "subject" => subject, "body" => body}, message)
      when is_list(recipients) do
    recipients
    |> Task.async_stream(fn to ->
      Logger.info("Received email for #{to} with subject #{subject}")
      send_email(to, subject, body)
    end,
      max_concurrency: 5,
      timeout: 30_000
    )
    |> Stream.run()

    message
  end

  def call(%{"to" => to, "subject" => subject, "body" => body}, message)
      when is_binary(to) do
    Logger.info("Received email for #{to} with subject #{subject}")
    send_email(to, subject, body)
    message
  end

  # Função privada que prepara e envia o e-mail
  defp send_email(to, subject, _body) do
    # email =
    #   new()
    #   |> to(to)
    #   |> from(System.get_env("SMTP_FROM") || "noreply@example.com")
    #   |> subject(subject)
    #   |> html_body(body)
    #
    # case Mailer.deliver(email) do
    #   {:ok, _} -> :ok
    #   {:error, reason} -> Logger.error("Failed to send email: #{inspect(reason)}")
    # end

    Logger.info("Pretending to send email to #{to} with subject #{subject}")
  end
end
