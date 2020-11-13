defmodule Watwitter.Avatar.TestClient do
  def generate(_email) do
    WatwitterWeb.Endpoint.static_url() <> "/test_image.png"
  end
end
