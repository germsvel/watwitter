defmodule WatwitterWeb.PageLiveTest do
  use WatwitterWeb.ConnCase

  import Phoenix.LiveViewTest

  test "disconnected and connected render", %{conn: conn} do
    {:ok, page_live, disconnected_html} = live(conn, "/")
    assert disconnected_html =~ "Watwitter"
    assert render(page_live) =~ "Watwitter"
  end
end
