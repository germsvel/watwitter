defmodule WatwitterWeb.PostComponentTest do
  use WatwitterWeb.ConnCase

  import Phoenix.LiveViewTest
  import Watwitter.Factory

  alias WatwitterWeb.PostComponent
  alias WatwitterWeb.DateHelpers

  test "renders post body and date" do
    post = insert(:post)

    html = render_component(PostComponent, post: post)

    assert html =~ post.body
    assert html =~ DateHelpers.format_short(post.inserted_at)
  end

  test "renders author's name, username, and avatar" do
    user = insert(:user)
    post = insert(:post, user: user)

    html = render_component(PostComponent, post: post)

    assert html =~ user.name
    assert html =~ "@#{user.username}"
    assert html =~ user.avatar_url
  end
end
