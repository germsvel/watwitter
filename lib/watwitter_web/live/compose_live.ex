defmodule WatwitterWeb.ComposeLive do
  use WatwitterWeb, :live_view

  alias Watwitter.Accounts
  alias WatwitterWeb.SVGHelpers

  def mount(_params, session, socket) do
    current_user = Accounts.get_user_by_session_token(session["user_token"])

    {:ok, assign(socket, current_user: current_user)}
  end
end
