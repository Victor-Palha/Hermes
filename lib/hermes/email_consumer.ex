defmodule Hermes.EmailConsumer do
  @moduledoc """
  A Broadway consumer that processes messages from an AWS SQS queue.
  It handles two types of messages: email and WhatsApp.
  If you want to add more message types, you can extend the `handle_message/3` function.
  Email messages are sent using the Swoosh library and SMTP adapter.
  WhatsApp messages are currently just logged to the console.
  Make sure to set the required environment variables for AWS and SMTP configuration.
  """

  use Broadway

  alias Hermes.Mailer
  import Swoosh.Email

  def start_link(_args) do
    Broadway.start_link(__MODULE__,
      name: __MODULE__,
      producer: [
        module:
          {BroadwaySQS.Producer,
           queue_url: System.fetch_env!("SQS_QUEUE_URL"),
           config: [
             access_key_id: [{:system, "AWS_ACCESS_KEY_ID"}, :instance_role],
             secret_access_key: [{:system, "AWS_SECRET_ACCESS_KEY"}, :instance_role],
             region: System.get_env("AWS_REGION") || "us-east-1"
           ]},
        concurrency: 2
      ],
      processors: [
        default: [concurrency: 10]
      ]
    )
  end

  @impl true
  def handle_message(_, %Broadway.Message{data: raw} = message, _) do
    with {:ok, decoded} <- Jason.decode(raw) do
      case decoded["type"] do
        "email" ->
          handle_email(decoded, message)
        "whatsapp" ->
          handle_whatsapp(decoded, message)
        _ ->
          IO.puts("Unknown message type: #{decoded["type"]}")
          Broadway.Message.failed(message, :unknown_message_type)
      end
    else
      {:error, reason} ->
        IO.puts("Failed to decode message: #{reason}")
        Broadway.Message.failed(message, :invalid_json)
    end
  end

  defp handle_email(%{"to" => to, "subject" => subject, "body" => body}, message) do
    email =
      new()
      |> to(to)
      |> from(System.get_env("SMTP_FROM") || "noreply@example.com")
      |> subject(subject)
      |> html_body(body)

    case Mailer.deliver(email) do
      {:ok, _} ->
        message

      {:error, reason} ->
        IO.puts("Failed to send email: #{inspect(reason)}")
        Broadway.Message.failed(message, reason)
    end
  end

  defp handle_whatsapp(%{"to" => to, "message" => msg}, message) do
    IO.puts("Received WhatsApp message for #{to}: #{msg}")
    message
  end
end
