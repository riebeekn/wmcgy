defmodule Wmcgy.Reports do
  @moduledoc """
  Context module for report specific functionality
  """
  alias Wmcgy.Accounts.User

  alias Wmcgy.Query
  alias Wmcgy.Repo
  alias Wmcgy.Reports.CategoryReport
  alias Wmcgy.Reports.MonthlyIncomeExpenseReport
  alias Wmcgy.Reports.YearlyIncomeExpenseReport

  # ===========================================================================
  def income_by_category_report(%User{} = user, opts \\ []) do
    start_date = Keyword.get(opts, :start_date)
    end_date = Keyword.get(opts, :end_date)

    user
    |> Query.Transactions.for_user()
    |> Query.Transactions.from_date(start_date)
    |> Query.Transactions.to_date(end_date)
    |> Query.Transactions.income()
    |> Query.Transactions.sum_by_category()
    |> Repo.all()
    |> CategoryReport.new(start_date, end_date, :income)
  end

  # ===========================================================================
  def expense_by_category_report(%User{} = user, opts \\ []) do
    start_date = Keyword.get(opts, :start_date)
    end_date = Keyword.get(opts, :end_date)

    user
    |> Query.Transactions.for_user()
    |> Query.Transactions.from_date(start_date)
    |> Query.Transactions.to_date(end_date)
    |> Query.Transactions.expense()
    |> Query.Transactions.sum_by_category()
    |> Repo.all()
    |> CategoryReport.new(start_date, end_date, :expense)
  end

  # ===========================================================================
  def monthly_income_expense_report(%User{} = user, start_year, start_month, end_year, end_month) do
    start_date = Date.new!(start_year, start_month, 1)
    end_date = Date.new!(end_year, end_month, 1) |> Date.end_of_month()

    incomes =
      user
      |> Query.Transactions.for_user()
      |> Query.Transactions.from_date(start_date)
      |> Query.Transactions.to_date(end_date)
      |> Query.Transactions.income()
      |> Query.Transactions.sum_by_month_and_year()
      |> Repo.all()

    expenses =
      user
      |> Query.Transactions.for_user()
      |> Query.Transactions.from_date(start_date)
      |> Query.Transactions.to_date(end_date)
      |> Query.Transactions.expense()
      |> Query.Transactions.sum_by_month_and_year()
      |> Repo.all()

    MonthlyIncomeExpenseReport.new(incomes, expenses, start_date, end_date)
  end

  # ===========================================================================
  def yearly_income_expense_report(%User{} = user, start_year, end_year) do
    start_date = Date.new!(start_year, 1, 1)
    end_date = Date.new!(end_year, 12, 31)

    incomes =
      user
      |> Query.Transactions.for_user()
      |> Query.Transactions.from_date(start_date)
      |> Query.Transactions.to_date(end_date)
      |> Query.Transactions.income()
      |> Query.Transactions.sum_by_year()
      |> Repo.all()

    expenses =
      user
      |> Query.Transactions.for_user()
      |> Query.Transactions.from_date(start_date)
      |> Query.Transactions.to_date(end_date)
      |> Query.Transactions.expense()
      |> Query.Transactions.sum_by_year()
      |> Repo.all()

    YearlyIncomeExpenseReport.new(incomes, expenses, start_year, end_year)
  end

  # ===========================================================================
  def profit_for_month(%User{} = user, year, month) do
    user
    |> Query.Transactions.for_user()
    |> Query.Transactions.sum_for_month(year, month)
    |> Repo.one()
    |> maybe_nil_to_zero()
  end

  # ===========================================================================
  def profit_for_year(%User{} = user, year) do
    user
    |> Query.Transactions.for_user()
    |> Query.Transactions.sum_for_year(year)
    |> Repo.one()
    |> maybe_nil_to_zero()
  end

  # ===========================================================================
  defp maybe_nil_to_zero(nil = _sum), do: Decimal.new(0)
  defp maybe_nil_to_zero(sum), do: sum
end
