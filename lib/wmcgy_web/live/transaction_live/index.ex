defmodule WmcgyWeb.TransactionLive.Index do
  use WmcgyWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.page_header_title>Transactions</.page_header_title>
    """
  end
end
