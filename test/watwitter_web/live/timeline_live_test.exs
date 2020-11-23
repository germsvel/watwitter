defmodule WatwitterWeb.TimelineLiveTest do
  use WatwitterWeb.ConnCase

  import Phoenix.LiveViewTest

  setup :register_and_log_in_user

  test "user can visit home page", %{conn: conn} do
    {:ok, view, html} = live(conn, "/")

    assert html =~ "Home"
    assert render(view) =~ "Home"
  end
end
