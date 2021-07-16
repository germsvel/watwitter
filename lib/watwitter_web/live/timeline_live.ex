defmodule WatwitterWeb.TimelineLive do
  use WatwitterWeb, :live_view

  alias Watwitter.Accounts
  alias Watwitter.Timeline
  alias WatwitterWeb.PostComponent
  alias WatwitterWeb.ShowPostComponent
  alias WatwitterWeb.SVGHelpers

  def mount(params, session, socket) do
    if connected?(socket), do: Timeline.subscribe()
    current_user = Accounts.get_user_by_session_token(session["user_token"])
    page = 1
    per_page = String.to_integer(params["per_page"] || "10")
    post_ids = Timeline.list_post_ids(page: page, per_page: per_page)

    {:ok,
     assign(socket,
       new_post_ids: [],
       new_posts_count: 0,
       current_post_id: nil,
       page: page,
       per_page: per_page,
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

  def handle_event("load-more", _, socket) do
    socket =
      socket
      |> update(:page, fn page -> page + 1 end)
      |> update_post_ids()

    {:noreply, socket}
  end

  defp update_post_ids(socket) do
    page = socket.assigns.page
    per_page = socket.assigns.per_page
    post_ids = Timeline.list_post_ids(page: page, per_page: per_page)

    socket
    |> update(:post_ids, fn existing -> existing ++ post_ids end)
  end
end
