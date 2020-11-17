defmodule Watwitter.Timeline.Like do
  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query

  alias Watwitter.Timeline.Post

  schema "likes" do
    field :user_id, :id
    field :post_id, :id

    timestamps()
  end

  @doc false
  def changeset(like, attrs) do
    like
    |> cast(attrs, [:user_id, :post_id])
    |> validate_required([:user_id, :post_id])
    |> prepare_changes(&increment_post_like_count/1)
  end

  defp increment_post_like_count(changeset) do
    if post_id = get_change(changeset, :post_id) do
      query = from Post, where: [id: ^post_id]
      changeset.repo.update_all(query, inc: [likes_count: 1])
    end

    changeset
  end
end
