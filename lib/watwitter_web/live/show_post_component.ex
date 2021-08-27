defmodule WatwitterWeb.ShowPostComponent do
  use WatwitterWeb, :live_component

  alias Watwitter.Timeline
  alias WatwitterWeb.SVGHelpers

  def preload(list_of_assigns) do
    list_of_ids = Enum.map(list_of_assigns, & &1.id)
    posts = Timeline.get_posts(list_of_ids)

    Enum.map(list_of_assigns, fn assigns ->
      Map.put(assigns, :post, Enum.find(posts, fn post -> post.id == assigns.id end))
    end)
  end

  def render(assigns) do
    ~L"""
    <div class="show-post" id="show-post-<%= @post.id %>">
      <div class="show-header">
        <img class="avatar" src="<%= @post.user.avatar_url %>">
        <div class="show-user-info">
          <span class="show-user-name">
            <%= @post.user.name %>
          </span>
          <span class="show-user-username">
            @<%= @post.user.username %>
          </span>
        </div>
      </div>

      <div class="show-body">
        <%= @post.body %>

        <div class="post-images">
          <%= for photo_url <- @post.photo_urls do %>
            <img class="post-image" data-role="post-image" src="<%= photo_url %>">
          <% end %>
        </div>
      </div>

      <div class="show-actions">
        <a class="post-action" href="#">
          <%= SVGHelpers.reply_svg() %>
        </a>
        <a class="post-action" href="#">
          <%= SVGHelpers.repost_svg() %>
          <span class="post-action-count"><%= @post.reposts_count %></span>
        </a>
        <%= if current_user_liked?(@post, @current_user) do %>
          <a class="post-action post-liked" href="#" data-role="post-liked">
            <%= SVGHelpers.liked_svg() %>
            <span class="post-action-count" data-role="like-count"><%= @post.likes_count %></span>
          </a>
        <% else %>
          <a class="post-action" href="#" data-role="like-button">
            <%= SVGHelpers.like_svg() %>
            <span class="post-action-count" data-role="like-count"><%= @post.likes_count %></span>
          </a>
        <% end %>
        <a class="post-action" href="#">
          <%= SVGHelpers.export_svg() %>
        </a>
      </div>
    </div>
    """
  end

  def current_user_liked?(post, user) do
    user.id in Enum.map(post.likes, & &1.user_id)
  end
end
