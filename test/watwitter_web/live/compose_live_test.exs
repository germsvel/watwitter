defmodule WatwitterWeb.ComposeLiveTest do
  use WatwitterWeb.ConnCase

  import Phoenix.LiveViewTest

  setup :register_and_log_in_user

  test "user can create a new post", %{conn: conn} do
    {:ok, view, _html} = live(conn, Routes.compose_path(conn, :new))

    {:ok, _view, html} =
      view
      |> form("#new-post", post: %{body: "This is awesome"})
      |> render_submit()
      |> follow_redirect(conn, Routes.timeline_path(conn, :index))

    assert html =~ "This is awesome"
  end

  test "user is notified if posting fails", %{conn: conn} do
    {:ok, view, _html} = live(conn, Routes.compose_path(conn, :new))

    rendered =
      view
      |> form("#new-post", post: %{body: nil})
      |> render_submit()

    assert rendered =~ "can&apos;t be blank"
  end

  test "user is notified of errors before form submission", %{conn: conn} do
    {:ok, view, _html} = live(conn, Routes.compose_path(conn, :new))

    rendered =
      view
      |> form("#new-post", post: %{body: nil})
      |> render_change()

    assert rendered =~ "can&apos;t be blank"
  end
end
