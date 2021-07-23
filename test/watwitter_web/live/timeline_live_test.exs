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

    assert view |> timeline_post(post1) |> has_element?()
    assert view |> timeline_post(post2) |> has_element?()
  end

  test "user can highlight post by clicking on it", %{conn: conn} do
    post = insert(:post)
    {:ok, view, _html} = live(conn, "/")

    view
    |> post_body(post)
    |> render_click()

    assert view |> highlighted_post(post) |> has_element?()
  end

  test "user can navigate to user settings", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    {:ok, conn} =
      view
      |> user_avatar()
      |> render_click()
      |> follow_redirect(conn, Routes.user_settings_path(conn, :edit))

    assert html_response(conn, 200) =~ "Settings"
  end

  test "user can compose new post from timeline", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    {:ok, _view, html} =
      view
      |> compose_button()
      |> render_click()
      |> follow_redirect(conn, Routes.compose_path(conn, :new))

    assert html =~ "Compose Watweet"
  end

  test "user receives notification of new posts in timeline", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")
    [post1, post2] = insert_pair(:post)

    Timeline.broadcast_post_created(post1)
    Timeline.broadcast_post_created(post2)

    assert view |> new_posts_notice("Show 2 posts") |> has_element?()
  end

  test "user can view new posts", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")
    new_post = insert(:post)
    Timeline.broadcast_post_created(new_post)

    view
    |> new_posts_notice("Show 1 post")
    |> render_click()

    assert view |> timeline_post(new_post) |> has_element?()
    refute view |> new_posts_notice() |> has_element?()
  end

  test "user sees new posts at the top of timeline", %{conn: conn} do
    previous_post = insert(:post)
    {:ok, view, _html} = live(conn, "/")
    new_post = insert(:post)
    Timeline.broadcast_post_created(new_post)

    rendered =
      view
      |> new_posts_notice("Show 1 post")
      |> render_click()

    [top_card, bottom_card] = all_post_cards(rendered)
    assert element_text(top_card) =~ new_post.body
    assert element_text(bottom_card) =~ previous_post.body
  end

  test "user sees new posts at the top of timeline (CSS selectors)", %{conn: conn} do
    insert(:post)
    {:ok, view, _html} = live(conn, "/")
    new_post = insert(:post)
    Timeline.broadcast_post_created(new_post)

    view
    |> new_posts_notice("Show 1 post")
    |> render_click()

    assert view |> first_post(new_post.body) |> has_element?()
  end

  test "updates rendered post when receiving a post-update message", %{conn: conn} do
    post = insert(:post, likes_count: 0)
    {:ok, view, _html} = live(conn, "/")
    updated_post = update_post(post, %{likes_count: 3})

    Timeline.broadcast_post_updated(updated_post)

    assert view |> post_like_count(updated_post, "3") |> has_element?()
  end

  test "user can see older posts with infinite scroll", %{conn: conn} do
    [oldest, newest] = insert_pair(:post)
    {:ok, view, _html} = live(conn, "/?per_page=1")

    view
    |> load_more_posts()
    |> render_hook("load-more")

    assert view |> timeline_post(newest) |> has_element?()
    assert view |> timeline_post(oldest) |> has_element?()
  end

  defp all_post_cards(html) do
    html
    |> Floki.parse_document!()
    |> Floki.find("[data-role='post']")
  end

  defp element_text(el), do: Floki.text(el)

  defp update_post(post, changes) do
    post
    |> Ecto.Changeset.change(changes)
    |> Watwitter.Repo.update!()
  end

  defp first_post(view, text) do
    element(view, "[data-role='post']:first-of-type", text)
  end

  def load_more_posts(view) do
    element(view, "#load-more", "Loading ...")
  end

  defp timeline_post(view, post) do
    element(view, post_card(post))
  end

  defp highlighted_post(view, post) do
    element(view, "#show-post-#{post.id}")
  end

  defp post_body(view, post) do
    element(view, post_card(post) <> " [data-role=show-post]", post.body)
  end

  defp post_like_count(view, post, count) do
    element(view, post_card(post) <> " [data-role=like-count]", count)
  end

  defp user_avatar(view) do
    element(view, "#user-avatar")
  end

  defp compose_button(view) do
    element(view, "#compose-button")
  end

  defp new_posts_notice(view, text \\ nil) do
    element(view, "#new-posts-notice", text)
  end

  defp post_card(post) do
    "#post-#{post.id}"
  end
end
