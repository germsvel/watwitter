defmodule Watwitter.Repo.Migrations.AssociatePostsAndUsers do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :user_id, references(:users), null: false
    end
  end
end
