defmodule WatwitterWeb.TimelineLiveTest do
  use WatwitterWeb.ConnCase

  import Phoenix.LiveViewTest
  import Watwitter.Factory

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
end
