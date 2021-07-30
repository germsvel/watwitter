defmodule Watwitter.Repo.Migrations.AddPhotoUrlsToPosts do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :photo_urls, {:array, :string}, null: false, default: []
    end
  end
end
