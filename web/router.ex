defmodule Pullhub.Router do
  use Pullhub.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Pullhub.Plugs.Authenticate
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Pullhub do
    pipe_through :browser # Use the default browser stack
    get "/", AuthController, :index
    get "/auth/:provider", AuthController, :request
    get "/auth/:provider/callback", AuthController, :callback
    post "/auth/:provider/callback", AuthController, :callback
    delete "/logout", AuthController, :delete

    post "/repositories/fetch_user_repos", RepositoryController, :fetch_user_repos
    resources "/repositories", RepositoryController
  end

  # Other scopes may use custom stacks.
  # scope "/api", Pullhub do
  #   pipe_through :api
  # end
end
