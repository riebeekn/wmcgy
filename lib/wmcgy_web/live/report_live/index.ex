defmodule WmcgyWeb.ReportLive.Index do
  @moduledoc """
  Live view for the reports page
  """
  use WmcgyWeb, :live_view

  # ===========================================================================
  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
