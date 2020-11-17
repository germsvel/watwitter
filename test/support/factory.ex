defmodule Watwitter.Factory do
  use ExMachina.Ecto, repo: Watwitter.Repo

  alias Watwitter.Accounts.User
  alias Watwitter.Timeline.Post

  def post_factory do
    %Post{
      body: sequence("This is a watweet"),
      user: build(:user),
      likes: []
    }
  end

  def user_factory(attrs) do
    default = %{
      name: "Gandalf",
      username: sequence("gandalf"),
      email: sequence(:email, &"user#{&1}@example.com"),
      password: "hello world!"
    }

    user_attrs = merge_attributes(default, attrs)

    %User{}
    |> User.registration_changeset(user_attrs)
    |> Ecto.Changeset.apply_changes()
  end

  def extract_user_token(fun) do
    {:ok, captured} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token, _] = String.split(captured.body, "[TOKEN]")
    token
  end
end
