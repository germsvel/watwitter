defmodule Watwitter.Avatar.Gravatar do
  @base_url "https://www.gravatar.com/avatar/"
  @backup_url "https://ui-avatars.com/api/"

  def generate(email) do
    hash = hash(email)
    default = default(email)

    @base_url <> hash <> "?d=#{default}"
  end

  defp hash(email) do
    email = String.downcase(email)

    :md5
    |> :crypto.hash(email)
    |> Base.encode16(case: :lower)
  end

  defp default(email) do
    [base, _] = String.split(email, "@")
    URI.encode_www_form(@backup_url <> "#{base}")
  end
end
