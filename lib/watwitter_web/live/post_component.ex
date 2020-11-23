defmodule WatwitterWeb.PostComponent do
  use WatwitterWeb, :live_component

  def render(assigns) do
    ~L"""
    <div id="post-<%= @post.id %>" class="post">
      <img class="avatar" src="">
      <div class="post-content">
        <div class="post-header">
          <div class="post-user-info">
            <span class="post-user-name">
            </span>
            <span class="post-user-username">
            </span>
          </div>

          <div class="post-date-info">
            <span class="post-date-separator">.</span>
            <span class="post-date">
            </span>
          </div>
        </div>

        <div class="post-body">
        </div>

        <div class="post-actions">
          <a class="post-action" href="#">
          </a>
        </div>
      </div>
    </div>
    """
  end
end
