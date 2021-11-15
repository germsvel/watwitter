defmodule Watwitter.CloudinaryUpload do
  def image_api_url(cloud_name) do
    "https://api.cloudinary.com/v1_1/#{cloud_name}/image/upload"
  end

  def image_url(cloud_name) do
    "https://res.cloudinary.com/#{cloud_name}/image/upload"
  end

  def sign_form_upload(fields_to_sign, credentials) do
    signature_fields = Map.put_new(fields_to_sign, :timestamp, generate_timestamp())

    signature = generate_signature(signature_fields, credentials)

    Map.merge(signature_fields, %{
      signature: signature,
      api_key: credentials.api_key
    })
  end

  defp generate_timestamp do
    DateTime.utc_now() |> DateTime.to_unix()
  end

  defp generate_signature(fields, creds) do
    sorted_fields =
      fields
      |> Map.keys()
      |> Enum.sort()
      |> Enum.reduce("", fn key, acc ->
        append_new_entry(key, fields, acc)
      end)

    sha1(sorted_fields <> creds.api_secret)
  end

  defp append_new_entry(key, fields, acc) do
    entry = "#{key}=#{fields[key]}"
    if acc == "", do: entry, else: acc <> "&" <> entry
  end

  defp sha1(value), do: :crypto.hash(:sha, value) |> Base.encode16(case: :lower)
end
