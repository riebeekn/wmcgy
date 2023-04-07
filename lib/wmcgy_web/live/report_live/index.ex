defmodule WmcgyWeb.ReportLive.Index do
  @moduledoc """
  Live view for the reports page
  """
  use WmcgyWeb, :live_view

  # ===========================================================================
  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Reports")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.flex_container>
      <.page_header_title>Reports</.page_header_title>
      <.live_component
        id="mtd_ytd"
        module={WmcgyWeb.Components.MtdYtdWidget}
        current_user={@current_user}
        today={@today}
      />
    </.flex_container>
    <.live_component
      module={WmcgyWeb.Components.Reports.IncomeExpenseByCategory}
      id="income_expense_by_category"
      current_user={@current_user}
      today={@today}
    />
    <.live_component
      module={WmcgyWeb.Components.Reports.IncomeExpenseByDate}
      id="income_expense_by_date"
      current_user={@current_user}
      today={@today}
    />
    """
  end
end
