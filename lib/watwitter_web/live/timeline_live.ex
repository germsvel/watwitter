defmodule WatwitterWeb.TimelineLive do
  use WatwitterWeb, :live_view

  alias Watwitter.Accounts
  alias Watwitter.Timeline
  alias WatwitterWeb.PostComponent
  alias WatwitterWeb.ShowPostComponent
  alias WatwitterWeb.SVGHelpers

  def mount(_params, session, socket) do
    if connected?(socket), do: Timeline.subscribe()
    current_user = Accounts.get_user_by_session_token(session["user_token"])
    posts = Timeline.list_posts()

    {:ok,
     assign(socket,
       new_posts: [],
       new_posts_count: 0,
       current_post: nil,
       posts: posts,
       current_user: current_user
     )}
  end

  def handle_params(%{"post_id" => post_id}, _, socket) do
    id = String.to_integer(post_id)
    current_post = Enum.find(socket.assigns.posts, fn post -> post.id == id end)

    {:noreply, assign(socket, current_post: current_post)}
  end

  def handle_params(_, _, socket) do
    {:noreply, socket}
  end

  def handle_info({:post_created, post}, socket) do
    {:noreply,
     socket
     |> update(:new_posts_count, fn count -> count + 1 end)
     |> update(:new_posts, fn posts -> [post | posts] end)}
  end

  def handle_event("show-new-posts", _, socket) do
    {:noreply,
     socket
     |> update(:posts, fn posts -> socket.assigns.new_posts ++ posts end)
     |> assign(:new_posts, [])
     |> assign(:new_posts_count, 0)}
  end
end
