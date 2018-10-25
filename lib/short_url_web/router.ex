defmodule ShortUrlWeb.Router do
  use ShortUrlWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ShortUrlWeb do
    # pipe_through :browser # Use the default browser stack

    get "/:code", UrlController, :redirect_to
  end

  # Other scopes may use custom stacks.
  scope "/url", ShortUrlWeb do
    pipe_through :api

    post "/", UrlController, :create
  end
end
