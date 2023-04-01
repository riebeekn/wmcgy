defmodule WmcgyWeb.LandingPageController do
  use WmcgyWeb, :controller

  def index(conn, _params) do
    render(conn, :index, layout: false)
  end
end
