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
    post_ids = Timeline.list_post_ids()

    {:ok,
     assign(socket,
       new_post_ids: [],
       new_posts_count: 0,
       current_post_id: nil,
       post_ids: post_ids,
       current_user: current_user
     )}
  end

  def handle_params(%{"post_id" => post_id}, _, socket) do
    id = String.to_integer(post_id)

    {:noreply, assign(socket, current_post_id: id)}
  end

  def handle_params(_, _, socket) do
    {:noreply, socket}
  end

  def handle_info({:post_created, post}, socket) do
    {:noreply,
     socket
     |> update(:new_posts_count, fn count -> count + 1 end)
     |> update(:new_post_ids, fn post_ids -> [post.id | post_ids] end)}
  end

  def handle_info({:post_updated, post}, socket) do
    send_update(PostComponent, id: post.id)

    {:noreply, socket}
  end

  def handle_event("show-new-posts", _, socket) do
    {:noreply,
     socket
     |> update(:post_ids, fn ids -> socket.assigns.new_post_ids ++ ids end)
     |> assign(:new_post_ids, [])
     |> assign(:new_posts_count, 0)}
  end
end
