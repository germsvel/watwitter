defmodule WatwitterWeb.TimelineLive do
  use WatwitterWeb, :live_view

  alias Watwitter.Accounts
  alias Watwitter.Timeline
  alias WatwitterWeb.PostComponent
  alias WatwitterWeb.ShowPostComponent
  alias WatwitterWeb.SVGHelpers

  def mount(_params, session, socket) do
    current_user = Accounts.get_user_by_session_token(session["user_token"])
    posts = Timeline.list_posts()

    {:ok, assign(socket, current_post: nil, posts: posts, current_user: current_user)}
  end

  def handle_event("select-post", %{"id" => post_id}, socket) do
    id = String.to_integer(post_id)
    current_post = Enum.find(socket.assigns.posts, fn post -> post.id == id end)

    {:noreply, assign(socket, current_post: current_post)}
  end
end
