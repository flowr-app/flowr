defmodule FlowrWeb.Developer.DeveloperController do
  use FlowrWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
