defmodule Watwitter.TimelineTest do
  use Watwitter.DataCase

  alias Watwitter.Timeline
  alias Watwitter.Timeline.Post

  describe "list_posts/1" do
    test "list_posts/0 returns list of posts" do
      post = insert(:post)
      assert Timeline.list_posts() == [post]
    end

    test "list_posts/1 accepts pagination" do
      insert_list(3, :post)

      assert [_post1, _post2] = Timeline.list_posts(page: 1, per_page: 2)
      assert [_post3] = Timeline.list_posts(page: 2, per_page: 2)
    end
  end

  describe "get_post!/1" do
    test "get_post!/1 returns the post with given id" do
      post = insert(:post)
      assert Timeline.get_post!(post.id) == post
    end
  end

  describe "create_post/1" do
    test "create_post/1 with valid data creates a post" do
      valid_attrs = %{body: "some body"}
      assert {:ok, %Post{} = post} = Timeline.create_post(valid_attrs)
      assert post.body == "some body"
      assert post.likes_count == 0
      assert post.reposts_count == 0
    end

    test "create_post/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Timeline.create_post(%{body: nil})
    end

    @two_hundred_and_fifty_one ~s"""
    Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod
      tempor incididunt ut labore et dolore magna aliqua. Ut tortor pretium
      viverra suspendisse potenti nullam ac. Turpis egestas maecenas pharetra
      convallis posuere morbi leonur
    """
    test "create_post/1 must have a body between 2-250 characters" do
      assert {:error, %Ecto.Changeset{}} = Timeline.create_post(%{body: "a"})

      assert {:error, %Ecto.Changeset{}} =
               Timeline.create_post(%{body: @two_hundred_and_fifty_one})
    end
  end

  describe "change_post/1" do
    test "change_post/1 returns a post changeset" do
      post = insert(:post)
      assert %Ecto.Changeset{} = Timeline.change_post(post)
    end
  end

  def insert_list(count, :post, attrs \\ %{}) do
    Stream.repeatedly(fn -> insert(:post, attrs) end)
    |> Enum.take(count)
  end

  def insert(:post, attrs \\ %{}) do
    default_attrs = %{body: "some body"}

    {:ok, post} =
      attrs
      |> Enum.into(default_attrs)
      |> Timeline.create_post()

    post
  end
end
