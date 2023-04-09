defmodule WmcgyWeb.ReportLive.Index do
  @moduledoc """
  Live view for the reports page
  """
  use WmcgyWeb, :live_view

  alias WmcgyWeb.Components.Reports.Layout

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
    <Layout.report_section_container title="Category reports">
      <.live_component
        module={WmcgyWeb.Components.Reports.IncomeExpenseByCategory}
        id="income_expense_by_category"
        current_user={@current_user}
        today={@today}
      />
    </Layout.report_section_container>
    <div class="mt-12">
      <Layout.report_section_container title="Date reports">
        <.live_component
          module={WmcgyWeb.Components.Reports.IncomeExpenseByDate}
          id="income_expense_by_date"
          current_user={@current_user}
          today={@today}
        />
      </Layout.report_section_container>
    </div>
    """
  end
end
