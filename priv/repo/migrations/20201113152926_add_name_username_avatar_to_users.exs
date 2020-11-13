defmodule Watwitter.Repo.Migrations.AddNameUsernameAvatarToUsers do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS citext", ""

    alter table(:users) do
      add :name, :string, null: false
      add :username, :citext, null: false
      add :avatar_url, :string, null: false
    end

    create unique_index(:users, [:username])
  end
end
