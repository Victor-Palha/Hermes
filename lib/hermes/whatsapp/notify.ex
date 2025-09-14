defmodule Hermes.Whatsapp.Notify do
  @moduledoc """
  A module to handle WhatsApp notifications.
  Supports sending to a single number or a list of numbers.
  """

  alias Hermes.Api.Adapter
  require Logger

  def call(%{"to" => recipients, "message" => msg}, message) when is_list(recipients) do
    recipients
    |> Task.async_stream(fn to ->
      Logger.info("Received WhatsApp message for #{to}: #{msg}")
      send_message(to, msg, message)
    end,
      max_concurrency: 5,
      timeout: 30_000
    )
    |> Stream.run()

    message
  end

  def call(%{"to" => to, "message" => msg}, message) when is_binary(to) do
    Logger.info("Received WhatsApp message for #{to}: #{msg}")
    send_message(to, msg, message)
  end

  defp send_message(to, msg, message) do
    url = "/#{System.get_env("WHATSAPP_PHONE_ID")}/messages"

    client =
      Adapter.build_client(
        System.get_env("WHATSAPP_API_URL"),
        System.get_env("WHATSAPP_API_ACCESS_TOKEN", "your_access_token")
      )

    payload = build_payload(to, [%{text: msg}])

    case Tesla.post(client, url, payload) do
      {:ok, response} ->
        Logger.info("WhatsApp message sent successfully: #{inspect(response)}")
        message

      {:error, reason} ->
        Logger.error("Failed to send WhatsApp message: #{inspect(reason)}")
        Broadway.Message.failed(message, :whatsapp_send_failed)
    end
  end

  defp build_payload(to, params) do
    %{
      messaging_product: "whatsapp",
      recipient_type: "individual",
      to: to,
      type: "template",
      template: %{
        name: "notificacao",
        language: %{code: "pt_BR"},
        components: [
          %{
            type: "body",
            parameters: Enum.map(params, fn %{text: text} ->
              %{type: "text", text: text}
            end)
          }
        ]
      }
    }
  end
end
