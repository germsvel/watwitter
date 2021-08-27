defmodule WatwitterWeb.ComposeLiveTest do
  use WatwitterWeb.ConnCase, async: false

  import Phoenix.LiveViewTest

  setup :register_and_log_in_user

  setup do
    on_exit(fn ->
      File.rm_rf!(uploads_dir())
      File.mkdir!(uploads_dir())
    end)
  end

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

  test "images are persisted and user can see them", %{conn: conn} do
    {:ok, view, _html} = live(conn, Routes.compose_path(conn, :new))

    {:ok, _, html} =
      view
      |> upload("moria-durins-door.png")
      |> post_watweet("Speak, friend, and enter")
      |> follow_redirect(conn, Routes.timeline_path(conn, :index))

    image_url = html |> find_image() |> get_src()

    assert conn |> get(image_url) |> response(200)
  end

  defp find_image(html) do
    html
    |> Floki.parse_document!()
    |> Floki.find("[data-role='post-image']")
    |> hd()
  end

  defp get_src(node) do
    [src] = Floki.attribute(node, "src")
    src
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

  defp uploads_dir do
    Application.app_dir(:watwitter, "priv/static/uploads")
  end
end
