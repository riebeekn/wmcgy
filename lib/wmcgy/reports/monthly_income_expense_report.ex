defmodule Wmcgy.Reports.MonthlyIncomeExpenseReport do
  @moduledoc """
  Module to represent a monthly income expense report
  """

  defmodule LineItem do
    @moduledoc """
    A line item for a monthly income expense report
    """
    @type t :: %__MODULE__{
            year: pos_integer(),
            month: pos_integer(),
            income: Decimal.t(),
            expense: Decimal.t(),
            profit_loss: Decimal.t()
          }
    defstruct [:year, :month, :income, :expense, :profit_loss]
  end

  @type t :: %__MODULE__{
          start_date: DateTime.t(),
          end_date: DateTime.t(),
          line_items: list(__MODULE__.LineItem.t())
        }

  defstruct [
    :start_date,
    :end_date,
    :line_items,
    :income_total,
    :expense_total,
    :profit_loss_total
  ]

  def new(monthly_incomes, monthly_expenses, start_date, end_date) do
    line_items =
      for year <- start_date.year..end_date.year do
        for month <-
              first_month_for_current_year(year, start_date)..last_month_for_current_year(
                year,
                end_date
              ) do
          income = maybe_find_amount_for_month_and_year(monthly_incomes, month, year)

          expense =
            maybe_find_amount_for_month_and_year(monthly_expenses, month, year) |> Decimal.abs()

          %LineItem{
            year: year,
            month: month,
            income: income,
            expense: expense,
            profit_loss: Decimal.sub(income, expense)
          }
        end
      end
      |> List.flatten()
      |> Enum.sort_by(&[&1.year, &1.month])

    income_total =
      Enum.reduce(line_items, Decimal.new(0), fn %{income: income}, acc ->
        Decimal.add(acc, income)
      end)

    expense_total =
      Enum.reduce(line_items, Decimal.new(0), fn %{expense: expense}, acc ->
        Decimal.add(acc, expense)
      end)

    %__MODULE__{
      start_date: start_date,
      end_date: end_date,
      income_total: income_total,
      expense_total: expense_total,
      profit_loss_total: Decimal.sub(income_total, expense_total),
      line_items: line_items
    }
  end

  defp maybe_find_amount_for_month_and_year(transactions, month, year) do
    transactions
    |> Enum.find(&(&1.year == year && &1.month == month))
    |> case do
      nil -> Decimal.new(0)
      transaction -> transaction.amount
    end
  end

  defp first_month_for_current_year(year, start_date) when year == start_date.year,
    do: start_date.month

  defp first_month_for_current_year(_year, _start_date), do: 1

  defp last_month_for_current_year(year, end_date) when year == end_date.year, do: end_date.month
  defp last_month_for_current_year(_year, _end_date), do: 12
end
