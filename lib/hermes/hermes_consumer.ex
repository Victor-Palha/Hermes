defmodule Hermes.HermesConsumer do
  @moduledoc """
  A Broadway consumer that processes messages from an AWS SQS queue.
  It handles two types of messages: email and WhatsApp.
  If you want to add more message types, you can extend the `handle_message/3` function.
  Email messages are sent using the Swoosh library and SMTP adapter.
  WhatsApp messages are currently just logged to the console.
  Make sure to set the required environment variables for AWS and SMTP configuration.
  """

  use Broadway

  alias Hermes.{Email, Whatsapp}

  def start_link(_args) do
    Broadway.start_link(__MODULE__,
      name: __MODULE__,
      producer: [
        module:
          {BroadwaySQS.Producer,
           queue_url: System.fetch_env!("SQS_QUEUE_URL"),
           config: [
             access_key_id: System.get_env("AWS_ACCESS_KEY_ID", "test"),
             secret_access_key: System.get_env("AWS_SECRET_ACCESS_KEY", "test"),
             region: System.get_env("AWS_REGION", "us-east-1"),
             scheme: System.get_env("AWS_SCHEME", "http://"),
             host: System.get_env("AWS_HOST", "localstack"),
             port: String.to_integer(System.get_env("AWS_PORT", "4566")),
             receive_message_wait_time_seconds: 5,
             wait_for_queue: true
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
          Email.Notify.call(decoded, message)

        "whatsapp" ->
          Whatsapp.Notify.call(decoded, message)

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
end
