# Welcome to Watwitter 🎉

Watwitter is a twitter(ish) clone to learn to test LiveView with my [Testing
LiveView] course.

## Getting set up

* Install Elixir, Erlang, and Node versions defined in
  [`.tool-versions`](./.tool-versions)
* Install dependencies with `mix deps.get`
* Create and migrate your database with `mix ecto.setup`
* Install Node.js dependencies with `npm install` inside the `assets` directory
* Run `mix test` to make sure all tests pass.
* Start Phoenix endpoint with `mix phx.server`

Now you can visit Watwtitter at [`localhost:4000`](http://localhost:4000).

## Following with the videos

Each video (aside from the intro) is associated with a particular branch. I
recommend checking out the appropriate branch for each video because sometimes I
do a little scaffolding in between lessons (just so that we don't have to worry
about the nitty-gritty details of HTML markup and CSS classes).

Here are the first 10 branches (so you get a sense of the pattern), and each
video will show which branch you should be on:

- `1-testing-rendering`
- `2-scoping-assertions`
- `3-rendering-component-list`
- `4-testing-live-components`
- `5-testing-live-components-part-2`
- `6-testing-page-interactions`
- `7-testing-live-patch`
- `8-testing-live-navigation`
- `9-testing-form-submission`
- `10-test-change-validation`
- ...

So for the video on Testing Rendering, you can `git checkout
1-testing-rendering`, and then implement the code following the lesson.

Happy testing! 🥳

## Resources

- [Testing LiveView course][Testing LiveView]
- [`Phoenix.LiveViewTest` docs](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveViewTest.html)

[Testing LiveView]: https://www.testingliveview.com/
