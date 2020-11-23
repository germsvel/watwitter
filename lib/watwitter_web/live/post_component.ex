defmodule WatwitterWeb.PostComponent do
  use WatwitterWeb, :live_component

  def render(assigns) do
    ~L"""
    <div id="post-<%= @post.id %>" class="post">
    </div>
    """
  end
end
