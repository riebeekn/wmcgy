defmodule WmcgyWeb.Components.Reports.IncomeExpenseByCategory do
  @moduledoc """
  Income and expense report component
  """
  use WmcgyWeb, :live_component

  alias Number.Currency
  alias WmcgyUtilities.DateHelpers

  # ===========================================================================
  @impl true
  def mount(socket) do
    {:ok,
     assign(socket,
       income_table_data: [],
       expense_table_data: [],
       expense_total: nil,
       income_total: nil
     )}
  end

  # ===========================================================================
  @impl true
  def update(%{today: nil} = assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign(:start_date_string, "")
      |> assign(:end_date_string, "")

    {:ok, socket}
  end

  # ===========================================================================
  @impl true
  def update(%{today: today} = assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign(:start_date_string, today |> Date.beginning_of_month() |> DateHelpers.to_string())
      |> assign(:end_date_string, today |> DateHelpers.to_string())

    {:ok, update_chart(socket, socket.assigns.start_date_string, socket.assigns.end_date_string)}
  end

  # ===========================================================================
  @impl true
  def handle_event(
        "start-date-changed",
        %{"start_date_form" => %{"start_date" => start_date_string}},
        socket
      ) do
    {:noreply, update_chart(socket, start_date_string, socket.assigns.end_date_string)}
  end

  # ===========================================================================
  @impl true
  def handle_event(
        "end-date-changed",
        %{"end_date_form" => %{"end_date" => end_date_string}},
        socket
      ) do
    {:noreply, update_chart(socket, socket.assigns.start_date_string, end_date_string)}
  end

  # ===========================================================================
  defp update_chart(socket, start_date_string, end_date_string) do
    {:ok, start_date} = start_date_string |> DateHelpers.parse()
    {:ok, end_date} = end_date_string |> DateHelpers.parse()

    expense_data =
      Wmcgy.expense_by_category_report(socket.assigns.current_user,
        start_date: start_date,
        end_date: end_date
      )

    income_data =
      Wmcgy.income_by_category_report(socket.assigns.current_user,
        start_date: start_date,
        end_date: end_date
      )

    socket
    |> assign(
      start_date_string: start_date_string,
      end_date_string: end_date_string,
      expense_table_data: expense_data.line_items,
      expense_total: expense_data.total_for_all_categories,
      income_table_data: income_data.line_items,
      income_total: income_data.total_for_all_categories
    )
    |> push_event(:expense_chart_update, %{
      labels: Enum.map(expense_data.line_items, & &1.category_name),
      values: Enum.map(expense_data.line_items, & &1.amount),
      percentages: Enum.map(expense_data.line_items, & &1.percentage)
    })
    |> push_event(:income_chart_update, %{
      labels: Enum.map(income_data.line_items, & &1.category_name),
      values: Enum.map(income_data.line_items, & &1.amount),
      percentages: Enum.map(income_data.line_items, & &1.percentage)
    })
  end
end
