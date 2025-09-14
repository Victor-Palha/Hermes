defmodule Hermes.Email.Notify do
  @moduledoc """
  A module to handle email notifications.
  Currently, it just logs the email details to the console.
  """

  # alias Hermes.Mailer
  # import Swoosh.Email

  def call(%{"to" => to, "subject" => subject, "body" => _body}, message) do
    IO.puts("Received email for #{to} with subject #{subject}")
    message

    # email =
    #   new()
    #   |> to(to)
    #   |> from(System.get_env("SMTP_FROM") || "noreply@example.com")
    #   |> subject(subject)
    #   |> html_body(body)

    # case Mailer.deliver(email) do
    #   {:ok, _} ->
    #     message

    #   {:error, reason} ->
    #     IO.puts("Failed to send email: #{inspect(reason)}")
    #     Broadway.Message.failed(message, reason)
    # end
  end
end
