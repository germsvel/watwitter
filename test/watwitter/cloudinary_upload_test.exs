defmodule Watwitter.CloudinaryUploadTest do
  use ExUnit.Case, async: true

  alias Watwitter.CloudinaryUpload

  describe "sign_form_upload/2" do
    test "returns fields with a generated signature" do
      fields = %{
        public_id: "sample_image",
        eager: "w_400,h_300,c_pad|w_260,h_200,c_crop",
        timestamp: 1_315_060_510
      }

      creds = %{
        api_key: "1234",
        api_secret: "abcd"
      }

      %{signature: signature} = CloudinaryUpload.sign_form_upload(fields, creds)

      assert signature == "bfd09f95f331f558cbd1320e67aa8d488770583e"
    end

    test "returns the api_key passed in" do
      fields = %{
        public_id: "sample_image",
        eager: "w_400,h_300,c_pad|w_260,h_200,c_crop",
        timestamp: 1_315_060_510
      }

      creds = %{
        api_key: "1234",
        api_secret: "abcd"
      }

      %{api_key: api_key} = CloudinaryUpload.sign_form_upload(fields, creds)

      assert api_key == "1234"
    end

    test "generates a timestamp when one isn't provided" do
      fields = %{
        public_id: "sample_image",
        eager: "w_400,h_300,c_pad|w_260,h_200,c_crop"
      }

      creds = %{
        api_key: "1234",
        api_secret: "abcd"
      }

      %{timestamp: timestamp} = CloudinaryUpload.sign_form_upload(fields, creds)

      refute is_nil(timestamp)
    end
  end
end
