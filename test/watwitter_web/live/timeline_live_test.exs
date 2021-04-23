defmodule WatwitterWeb.TimelineLiveTest do
  use WatwitterWeb.ConnCase

  import Phoenix.LiveViewTest
  import Watwitter.Factory

  alias Watwitter.Timeline

  setup :register_and_log_in_user

  test "user can visit home page", %{conn: conn} do
    {:ok, view, html} = live(conn, "/")

    assert html =~ "Home"
    assert render(view) =~ "Home"
  end

  test "current user can see own avatar", %{conn: conn, user: user} do
    {:ok, view, _html} = live(conn, "/")

    avatar = element(view, "img[src*=#{user.avatar_url}]")

    assert has_element?(avatar)
  end

  test "renders a list of posts", %{conn: conn} do
    [post1, post2] = insert_pair(:post)
    {:ok, view, _html} = live(conn, "/")

    assert has_element?(view, "#post-#{post1.id}")
    assert has_element?(view, "#post-#{post2.id}")
  end

  test "user can highlight post by clicking on it", %{conn: conn} do
    post = insert(:post)
    {:ok, view, _html} = live(conn, "/")

    view
    |> element("#post-#{post.id} [data-role=show-post]", post.body)
    |> render_click()

    assert has_element?(view, "#show-post-#{post.id}")
  end

  test "user can navigate to user settings", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    {:ok, conn} =
      view
      |> element("#user-avatar")
      |> render_click()
      |> follow_redirect(conn, Routes.user_settings_path(conn, :edit))

    assert html_response(conn, 200) =~ "Settings"
  end

  test "user can compose new post from timeline", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    {:ok, _view, html} =
      view
      |> element("#compose-button")
      |> render_click()
      |> follow_redirect(conn, Routes.compose_path(conn, :new))

    assert html =~ "Compose Watweet"
  end

  test "user receives notification of new posts in timeline", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")
    [post1, post2] = insert_pair(:post)

    Timeline.broadcast_post_created(post1)
    Timeline.broadcast_post_created(post2)

    assert has_element?(view, "#new-posts-notice", "Show 2 posts")
  end

  test "user can view new posts", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")
    new_post = insert(:post)
    Timeline.broadcast_post_created(new_post)

    view
    |> element("#new-posts-notice", "Show 1 post")
    |> render_click()

    assert has_element?(view, "#post-#{new_post.id}")
    refute has_element?(view, "#new-posts-notice")
  end

  test "updates rendered post when receiving a post-update message", %{conn: conn} do
    post = insert(:post, likes_count: 0)
    {:ok, view, _html} = live(conn, "/")
    updated_post = update_post(post, %{likes_count: 3})

    Timeline.broadcast_post_updated(updated_post)

    assert has_element?(view, "#post-#{updated_post.id} [data-role=like-count]", "3")
  end

  defp update_post(post, changes) do
    post
    |> Ecto.Changeset.change(changes)
    |> Watwitter.Repo.update!()
  end
end
