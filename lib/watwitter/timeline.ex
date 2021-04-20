defmodule Watwitter.Timeline do
  @moduledoc """
  The Timeline context.
  """

  import Ecto.Query, warn: false

  alias Watwitter.Accounts.User
  alias Watwitter.Repo
  alias Watwitter.Timeline.{Like, Post}

  @doc """
  Returns the list of posts.

  ## Examples

      iex> list_posts(page: 1, per_page: 2)
      [%Post{}, ...]

  """
  def list_posts(opts \\ []) do
    page = Keyword.get(opts, :page, 1)
    per_page = Keyword.get(opts, :per_page, 10)

    from(p in Post,
      offset: ^((page - 1) * per_page),
      limit: ^per_page,
      order_by: [desc: p.id]
    )
    |> Repo.all()
    |> Repo.preload([:user, :likes])
  end

  @doc """
  Returns the list of post ids.

  ## Examples

      iex> list_post_ids(page: 1, per_page: 2)
      [1, ...]

  """
  def list_post_ids(opts \\ []) do
    page = Keyword.get(opts, :page, 1)
    per_page = Keyword.get(opts, :per_page, 10)

    from(p in Post,
      select: p.id,
      offset: ^((page - 1) * per_page),
      limit: ^per_page,
      order_by: [desc: p.id]
    )
    |> Repo.all()
  end

  @doc """
  Returns the list of posts given a set of ids.

  ## Examples

      iex> get_posts([1, 2], page: 1, per_page: 2)
      [%Post{id: 1}, ...]

  """
  def get_posts(ids, opts \\ []) do
    page = Keyword.get(opts, :page, 1)
    per_page = Keyword.get(opts, :per_page, 10)

    from(p in Post,
      where: p.id in ^ids,
      offset: ^((page - 1) * per_page),
      limit: ^per_page,
      order_by: [desc: p.id]
    )
    |> Repo.all()
    |> Repo.preload([:user, :likes])
  end

  @doc """
  Gets a single post.

  Raises `Ecto.NoResultsError` if the Post does not exist.

  ## Examples

      iex> get_post!(123)
      %Post{}

      iex> get_post!(456)
      ** (Ecto.NoResultsError)

  """
  def get_post!(id), do: Post |> Repo.get!(id) |> Repo.preload([:user, :likes])

  @doc """
  Creates a post.

  ## Examples

      iex> create_post(%{field: value})
      {:ok, %Post{}}

      iex> create_post(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_post(attrs \\ %{}) do
    %Post{}
    |> Post.changeset(attrs)
    |> Repo.insert()
    |> preload_timeline_data()
    |> broadcast(:post_created)
  end

  defp preload_timeline_data({:error, _} = error), do: error
  defp preload_timeline_data({:ok, post}), do: {:ok, Repo.preload(post, [:user, :likes])}

  @doc """
  Likes a post.

  ## Examples

      iex> like_post!(post, user)
      %Post{}

      iex> like_post!(%{id: nil}, %{id: nil})
      ** (Ecto.NoResultsError)

  """
  def like_post!(%Post{} = post, %User{} = user) do
    %Like{}
    |> Like.changeset(%{post_id: post.id, user_id: user.id})
    |> Repo.insert!()

    get_post!(post.id)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking post changes.

  ## Examples

      iex> change_post(post)
      %Ecto.Changeset{data: %Post{}}

  """
  def change_post(%Post{} = post, attrs \\ %{}) do
    Post.changeset(post, attrs)
  end

  @doc """
  Subscribes process to timeline events
  """
  @timeline_topic "timeline"
  def subscribe do
    Phoenix.PubSub.subscribe(Watwitter.PubSub, @timeline_topic)
  end

  def broadcast_post_created(post) do
    Phoenix.PubSub.broadcast(Watwitter.PubSub, @timeline_topic, {:post_created, post})
  end

  def broadcast_post_updated(post) do
    Phoenix.PubSub.broadcast(Watwitter.PubSub, @timeline_topic, {:post_updated, post})
  end

  defp broadcast({:error, _} = error, _), do: error

  defp broadcast({:ok, post} = ok_tuple, _event) do
    broadcast_post_created(post)
    ok_tuple
  end
end
