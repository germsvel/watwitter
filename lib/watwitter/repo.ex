defmodule Watwitter.Repo do
  use Ecto.Repo,
    otp_app: :watwitter,
    adapter: Ecto.Adapters.Postgres
end
