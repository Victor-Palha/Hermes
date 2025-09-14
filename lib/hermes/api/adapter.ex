defmodule Hermes.Api.Adapter do
  @spec build_client(base_url :: String.t(), api_token :: String.t()) :: Tesla.Client.t()
  def build_client(base_url, api_token) do
    Tesla.client([
      {Tesla.Middleware.BaseUrl, base_url},
      {Tesla.Middleware.Headers, [{"Authorization", "Bearer #{api_token}"}]},
      Tesla.Middleware.JSON
    ])
  end
end
