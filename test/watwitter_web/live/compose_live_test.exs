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

  test "user sees image preview when uploading an image", %{conn: conn} do
    {:ok, view, _html} = live(conn, Routes.compose_path(conn, :new))

    view |> upload("moria-durins-door.png")

    assert has_element?(view, "[data-role='photo-preview']")
  end

  test "user can cancel an upload", %{conn: conn} do
    {:ok, view, _html} = live(conn, Routes.compose_path(conn, :new))

    view
    |> upload("moria-durins-door.png")
    |> cancel_upload()

    refute has_element?(view, "[data-role='photo-preview']")
  end

  test "user sees error when uploading too many files", %{conn: conn} do
    {:ok, view, _html} = live(conn, Routes.compose_path(conn, :new))

    view
    |> upload("moria-durins-door.png")
    |> upload("moria-durins-door.png")
    |> upload("moria-durins-door.png")

    assert render(view) =~ "Too many files"
  end

  test "user submits post with images", %{conn: conn} do
    {:ok, view, _html} = live(conn, Routes.compose_path(conn, :new))

    {:ok, timeline, _html} =
      view
      |> upload("moria-durins-door.png")
      |> post_watweet("Speak, friend, and enter")
      |> follow_redirect(conn, Routes.timeline_path(conn, :index))

    assert render(timeline) =~ "Speak, friend, and enter"
    assert has_element?(timeline, "[data-role='post-image']")
  end

  test "failing to submit post does not remove image previews", %{conn: conn} do
    {:ok, view, _html} = live(conn, Routes.compose_path(conn, :new))

    view
    |> upload("moria-durins-door.png")
    |> post_watweet(nil)

    assert has_element?(view, "[data-role='photo-preview']")
  end

  defp post_watweet(view, text) do
    view
    |> form("#new-post", post: %{body: text})
    |> render_submit()
  end

  defp upload(view, filename) do
    view
    |> file_input("#new-post", :photos, [
      %{
        name: filename,
        content: File.read!("test/support/images/#{filename}"),
        type: "image/png"
      }
    ])
    |> render_upload(filename)

    view
  end

  defp cancel_upload(view) do
    view
    |> element("[name='cancel-upload']")
    |> render_click()
  end
end
