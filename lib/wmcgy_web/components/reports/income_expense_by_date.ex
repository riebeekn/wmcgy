defmodule WmcgyWeb.Components.Reports.IncomeExpenseByDate do
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
       date_options: [],
       current_date_option: nil,
       income_expense_table_data: [],
       income_total: nil,
       expense_total: nil,
       profit_loss_total: nil
     )}
  end

  # ===========================================================================
  @impl true
  def update(%{today: nil} = assigns, socket) do
    socket =
      socket
      |> assign(assigns)

    {:ok, socket}
  end

  # ===========================================================================
  @impl true
  def update(%{today: today} = assigns, socket) do
    default_date_options = [
      %{id: "ytd", label: "year to date"},
      %{id: "last_12", label: "last 12 months"},
      %{id: "all", label: "all"}
    ]

    years_with_transactions = Wmcgy.years_with_transactions(assigns.current_user)

    user_date_options =
      years_with_transactions
      |> Enum.filter(&(&1 != today.year))
      |> Enum.map(&%{id: &1, label: &1})

    options = default_date_options ++ user_date_options

    socket =
      socket
      |> assign(assigns)
      |> assign(:date_options, options)
      |> assign(:current_date_option, "ytd")
      |> assign(:first_year_with_transactions, year_or_nil(years_with_transactions, &Enum.min/1))
      |> assign(:last_year_with_transactions, year_or_nil(years_with_transactions, &Enum.max/1))
      |> calculate_period("ytd")
      |> update_chart()

    {:ok, socket}
  end

  defp year_or_nil([], _), do: nil
  defp year_or_nil(years_with_transactions, func), do: func.(years_with_transactions)

  # ===========================================================================
  @impl true
  def handle_event(
        "date-option-selected",
        %{"date_options_form" => %{"date_option" => option}},
        socket
      ) do
    socket =
      socket
      |> calculate_period(option)
      |> update_chart()

    {:noreply, socket}
  end

  # ===========================================================================
  defp calculate_period(socket, "ytd") do
    {socket,
     %{
       start_year: socket.assigns.today.year,
       start_month: 1,
       end_year: socket.assigns.today.year,
       end_month: socket.assigns.today.month
     }}
  end

  defp calculate_period(socket, "last_12") do
    {socket,
     %{
       start_year: socket.assigns.today.year - 1,
       start_month: rem(socket.assigns.today.month + 1, 12),
       end_year: socket.assigns.today.year,
       end_month: socket.assigns.today.month
     }}
  end

  defp calculate_period(socket, "all") do
    {socket,
     %{
       start_year: socket.assigns.first_year_with_transactions,
       end_year: socket.assigns.last_year_with_transactions
     }}
  end

  defp calculate_period(socket, year) do
    year = String.to_integer(year)
    {socket, %{start_year: year, start_month: 1, end_year: year, end_month: 12}}
  end

  # ===========================================================================
  defp update_chart(
         {socket,
          %{
            start_year: start_year,
            start_month: start_month,
            end_year: end_year,
            end_month: end_month
          }}
       ) do
    income_expense_data =
      Wmcgy.monthly_income_expense_report(
        socket.assigns.current_user,
        start_year,
        start_month,
        end_year,
        end_month
      )

    socket
    |> assign_data_to_socket(income_expense_data)
  end

  defp update_chart({socket, %{start_year: start_year, end_year: end_year}}) do
    income_expense_data =
      Wmcgy.yearly_income_expense_report(socket.assigns.current_user, start_year, end_year)

    socket
    |> assign_data_to_socket(income_expense_data)
  end

  # ===========================================================================
  defp assign_data_to_socket(socket, income_expense_data) do
    socket
    |> assign(:income_expense_table_data, income_expense_data.line_items)
    |> assign(:income_total, income_expense_data.income_total)
    |> assign(:expense_total, income_expense_data.expense_total)
    |> assign(:profit_loss_total, income_expense_data.profit_loss_total)
    |> push_event(:income_expense_chart_update, %{
      labels: Enum.map(income_expense_data.line_items, &month_or_year_label/1),
      datasets: [
        %{
          label: "Income",
          data: Enum.map(income_expense_data.line_items, & &1.income)
        },
        %{
          label: "Expense",
          data: Enum.map(income_expense_data.line_items, & &1.expense)
        }
      ]
    })
    |> push_event(:profit_loss_chart_update, %{
      labels: Enum.map(income_expense_data.line_items, &month_or_year_label/1),
      datasets: [
        %{
          label: "Profit",
          data: Enum.map(income_expense_data.line_items, &profit_value(&1.profit_loss))
        },
        %{
          label: "Loss",
          data: Enum.map(income_expense_data.line_items, &loss_value(&1.profit_loss))
        }
      ]
    })
  end

  # ===========================================================================
  defp profit_value(profit_loss) do
    if Decimal.gt?(profit_loss, 0) do
      profit_loss
    else
      Decimal.new(0)
    end
  end

  # ===========================================================================
  defp loss_value(profit_loss) do
    if Decimal.lt?(profit_loss, 0) do
      profit_loss
    else
      Decimal.new(0)
    end
  end

  # ===========================================================================
  defp month_or_year_label(%{month: month}), do: month |> DateHelpers.month_shortname()
  defp month_or_year_label(%{year: year}), do: year
end
