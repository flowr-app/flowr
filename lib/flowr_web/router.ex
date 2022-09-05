defmodule FlowrWeb.Router do
  use FlowrWeb, :router
  import Phoenix.LiveView.Router
  import Phoenix.LiveDashboard.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :put_root_layout, {FlowrWeb.LayoutView, :root}
    plug FlowrWeb.Plugs.SetCurrentCustomer
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :dashboard do
    plug FlowrWeb.Plugs.AuthenticateCustomer
    plug :put_layout, {FlowrWeb.LayoutView, :dashboard}
  end

  pipeline :developer do
    plug :put_layout, {FlowrWeb.LayoutView, :developer}
  end

  scope "/", FlowrWeb do
    pipe_through :browser

    get "/", PageController, :index

    resources "/templates", TemplateController

    scope "/developer", as: :developer, alias: Developer do
      pipe_through :developer

      get "/", DeveloperController, :index

      resources "/connectors", ConnectorController
    end

    scope "/dashboard", as: :dashboard, alias: Dashboard do
      pipe_through [:dashboard]

      get "/", DashboardController, :index

      resources "/subscriptions", SubscriptionController do
        resources "/logs", Subscription.LogController, only: [:index]
      end

      resources "/pollings", PollingController do
        resources "/items", Polling.ItemController, only: [:index]
      end

      resources "/triggers", TriggerController

      get "/tasks", FlowTaskController, :index_all, as: :task
      resources "/tasks", FlowTaskController, as: :task, only: [:show]

      resources "/flows", FlowController do
        resources "/tasks", FlowTaskController, as: :task, only: [:index]
      end

      resources "/connectors", ConnectorController, only: [:index]

      resources "/connector_accounts", AccountController, as: :connector_account

      get "/connector_accounts/:id/auth", AccountController, :auth, as: :connector_account
    end
  end

  scope "/auth", FlowrWeb do
    pipe_through(:browser)

    get "/new", AuthController, :new
    get "/callback", AuthController, :callback
    delete "/sign-out", AuthController, :delete
  end

  # Other scopes may use custom stacks.
  scope path: "/api", as: :api, alias: FlowrWeb.API do
    pipe_through :api

    post("/subscriptions/:id/", SubscriptionController, :create)
    post("/webhook/:id/", WebhookController, :create)
    get("/connectors/callback", ConnectorAccountController, :callback)
  end

  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard",
        ecto_repos: [Flowr.Repo],
        additional_pages: [
          broadway: {BroadwayDashboard, pipelines: [Flowr.Automation.Workflow]}
        ]
    end
  end
end
