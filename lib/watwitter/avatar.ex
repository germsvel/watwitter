defmodule Watwitter.Avatar do
  def generate(email) when is_binary(email) do
    avatar_client().generate(email)
  end

  defp avatar_client do
    Application.get_env(:watwitter, :avatar_client)
  end
end
