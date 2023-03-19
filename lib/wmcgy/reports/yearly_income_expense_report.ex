defmodule Wmcgy.Reports.YearlyIncomeExpenseReport do
  @moduledoc """
  Module to represent a yearly income expense report
  """

  defmodule LineItem do
    @moduledoc """
    A line item for a yearly income expense report
    """
    @type t :: %__MODULE__{
            year: pos_integer(),
            income: Decimal.t(),
            expense: Decimal.t()
          }
    defstruct [:year, :income, :expense, :profit_loss]
  end

  @type t :: %__MODULE__{
          start_year: pos_integer(),
          end_year: pos_integer(),
          income_total: Decimal.t(),
          expense_total: Decimal.t(),
          profit_loss_total: Decimal.t(),
          line_items: list(__MODULE__.LineItem.t())
        }

  defstruct [
    :start_year,
    :end_year,
    :income_total,
    :expense_total,
    :profit_loss_total,
    :line_items
  ]

  def new(yearly_incomes, yearly_expenses, start_year, end_year) do
    line_items =
      for year <- start_year..end_year do
        income = maybe_find_amount_for_year(yearly_incomes, year)
        expense = maybe_find_amount_for_year(yearly_expenses, year) |> Decimal.abs()

        %LineItem{
          year: year,
          income: income,
          expense: expense,
          profit_loss: Decimal.sub(income, expense)
        }
      end
      |> Enum.sort_by(& &1.year)

    income_total =
      Enum.reduce(line_items, Decimal.new(0), fn %{income: income}, acc ->
        Decimal.add(acc, income)
      end)

    expense_total =
      Enum.reduce(line_items, Decimal.new(0), fn %{expense: expense}, acc ->
        Decimal.add(acc, expense)
      end)

    %__MODULE__{
      start_year: start_year,
      end_year: end_year,
      income_total: income_total,
      expense_total: expense_total,
      profit_loss_total: Decimal.sub(income_total, expense_total),
      line_items: line_items
    }
  end

  defp maybe_find_amount_for_year(transactions, year) do
    transactions
    |> Enum.find(&(&1.year == year))
    |> case do
      nil -> Decimal.new(0)
      transaction -> transaction.amount
    end
  end
end
