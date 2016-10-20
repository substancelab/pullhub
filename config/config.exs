# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :pullhub,
  ecto_repos: [Pullhub.Repo]

# Configures the endpoint
config :pullhub, Pullhub.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "p2BnMs87klYQkiYcMtlTBzrH1nQX+OHbR0Ixfd61ySN8yJev805GN8MjVVTGV3Te",
  render_errors: [view: Pullhub.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Pullhub.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :ueberauth, Ueberauth,
  providers: [
    github: { Ueberauth.Strategy.Github, [ default_scope: "user:email, repo" ] }
  ]

config :ueberauth, Ueberauth.Strategy.Github.OAuth,
  client_id: System.get_env("GITHUB_CLIENT_ID") || "adec11fb9e64770aeb67",
  client_secret: System.get_env("GITHUB_CLIENT_SECRET") || "a7eed573d14ecf909e3cde6064e66d8e105fef1a"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
