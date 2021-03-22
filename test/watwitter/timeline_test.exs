defmodule Watwitter.TimelineTest do
  use Watwitter.DataCase

  import Watwitter.Factory

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

  describe "list_post_ids/1" do
    test "returns a list of post ids" do
      post = insert(:post)
      assert Timeline.list_post_ids() == [post.id]
    end

    test "list_post_ids/1 accepts pagination" do
      insert_list(3, :post)

      assert [_id1, _id2] = Timeline.list_post_ids(page: 1, per_page: 2)
      assert [_id3] = Timeline.list_post_ids(page: 2, per_page: 2)
    end
  end

  describe "get_posts/2" do
    test "returns a list of post based on ids" do
      %{id: id} = insert(:post)

      [post] = Timeline.get_posts([id])

      assert post.id == id
    end

    test "accepts pagination" do
      posts = insert_list(3, :post)
      ids = Enum.map(posts, & &1.id)

      assert [_id1, _id2] = Timeline.get_posts(ids, page: 1, per_page: 2)
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
      user = insert(:user)
      valid_attrs = params_for(:post, user_id: user.id)
      assert {:ok, %Post{} = post} = Timeline.create_post(valid_attrs)
      assert post.body == valid_attrs.body
      assert post.likes_count == 0
      assert post.reposts_count == 0
      assert post.user_id == user.id
    end

    test "broadcast post creation" do
      Timeline.subscribe()
      user = insert(:user)
      params = params_for(:post, user_id: user.id)

      {:ok, post} = Timeline.create_post(params)

      assert_receive {:post_created, ^post}
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

  describe "like_post!/2" do
    test "creates a like for user and post" do
      user = insert(:user)
      post = insert(:post)

      updated_post = Timeline.like_post!(post, user)

      assert [like] = updated_post.likes
      assert like.user_id == user.id
      assert like.post_id == post.id
    end

    test "increments a post's likes count" do
      [user1, user2] = insert_pair(:user)
      post = insert(:post, likes_count: 0)

      _updated_post = Timeline.like_post!(post, user1)
      updated_post = Timeline.like_post!(post, user2)

      assert updated_post.likes_count == 2
    end
  end

  describe "change_post/1" do
    test "change_post/1 returns a post changeset" do
      post = insert(:post)
      assert %Ecto.Changeset{} = Timeline.change_post(post)
    end
  end
end
