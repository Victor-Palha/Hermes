defmodule Hermes.Whatsapp.Notify do
  @moduledoc """
  A module to handle WhatsApp notifications.
  Currently, it just logs the message to the console.
  """

  def call(%{"to" => to, "message" => msg}, message) do
    IO.puts("Received WhatsApp message for #{to}: #{msg}")
    message
  end
end
