defmodule WatwitterWeb.ComposeLive do
  use WatwitterWeb, :live_view

  alias Watwitter.Accounts
  alias Watwitter.Timeline
  alias Watwitter.Timeline.Post
  alias WatwitterWeb.SVGHelpers

  def mount(_params, session, socket) do
    current_user = Accounts.get_user_by_session_token(session["user_token"])
    changeset = Timeline.change_post(%Post{})

    {:ok, assign(socket, changeset: changeset, current_user: current_user)}
  end

  def handle_event("save", %{"post" => post_params}, socket) do
    current_user = socket.assigns.current_user
    params = Map.put(post_params, "user_id", current_user.id)

    case Timeline.create_post(params) do
      {:ok, _post} ->
        {:noreply, push_redirect(socket, to: Routes.timeline_path(socket, :index))}

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("validate", %{"post" => post_params}, socket) do
    current_user = socket.assigns.current_user
    params = Map.put(post_params, "user_id", current_user.id)

    changeset =
      %Post{}
      |> Timeline.change_post(params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end
end
