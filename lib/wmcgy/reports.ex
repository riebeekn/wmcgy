defmodule Wmcgy.Reports do
  @moduledoc """
  Context module for report specific functionality
  """
  alias Wmcgy.Accounts.User

  alias Wmcgy.Query.Transaction
  alias Wmcgy.Repo
  alias Wmcgy.Reports.CategoryReport
  alias Wmcgy.Reports.MonthlyIncomeExpenseReport
  alias Wmcgy.Reports.YearlyIncomeExpenseReport

  # ===========================================================================
  def income_by_category_report(%User{} = user, opts \\ []) do
    start_date = Keyword.get(opts, :start_date)
    end_date = Keyword.get(opts, :end_date)

    user
    |> Transaction.for_user()
    |> Transaction.from_date(start_date)
    |> Transaction.to_date(end_date)
    |> Transaction.income()
    |> Transaction.sum_by_category()
    |> Repo.all()
    |> CategoryReport.new(start_date, end_date, :income)
  end

  # ===========================================================================
  def expense_by_category_report(%User{} = user, opts \\ []) do
    start_date = Keyword.get(opts, :start_date)
    end_date = Keyword.get(opts, :end_date)

    user
    |> Transaction.for_user()
    |> Transaction.from_date(start_date)
    |> Transaction.to_date(end_date)
    |> Transaction.expense()
    |> Transaction.sum_by_category()
    |> Repo.all()
    |> CategoryReport.new(start_date, end_date, :expense)
  end

  # ===========================================================================
  def monthly_income_expense_report(%User{} = user, start_year, start_month, end_year, end_month) do
    start_date = Date.new!(start_year, start_month, 1)
    end_date = Date.new!(end_year, end_month, 1) |> Date.end_of_month()

    incomes =
      user
      |> Transaction.for_user()
      |> Transaction.from_date(start_date)
      |> Transaction.to_date(end_date)
      |> Transaction.income()
      |> Transaction.sum_by_month_and_year()
      |> Repo.all()

    expenses =
      user
      |> Transaction.for_user()
      |> Transaction.from_date(start_date)
      |> Transaction.to_date(end_date)
      |> Transaction.expense()
      |> Transaction.sum_by_month_and_year()
      |> Repo.all()

    MonthlyIncomeExpenseReport.new(incomes, expenses, start_date, end_date)
  end

  # ===========================================================================
  def yearly_income_expense_report(%User{} = user, start_year, end_year) do
    start_date = Date.new!(start_year, 1, 1)
    end_date = Date.new!(end_year, 12, 31)

    incomes =
      user
      |> Transaction.for_user()
      |> Transaction.from_date(start_date)
      |> Transaction.to_date(end_date)
      |> Transaction.income()
      |> Transaction.sum_by_year()
      |> Repo.all()

    expenses =
      user
      |> Transaction.for_user()
      |> Transaction.from_date(start_date)
      |> Transaction.to_date(end_date)
      |> Transaction.expense()
      |> Transaction.sum_by_year()
      |> Repo.all()

    YearlyIncomeExpenseReport.new(incomes, expenses, start_year, end_year)
  end
end
