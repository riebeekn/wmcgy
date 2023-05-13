defmodule Wmcgy do
  @moduledoc """
  API for the application, all calls from the front-end should go thru
  this module vs directly calling into individual context modules.
  """
  use Boundary,
    deps: [WmcgySchema, WmcgyUtilities],
    exports: [Accounts, Accounts.User, Emails.Gallery, TransactionImport.ImportProgress]

  alias Wmcgy.Accounts.User
  alias Wmcgy.Reports.CategoryReport
  alias Wmcgy.Reports.MonthlyIncomeExpenseReport
  alias Wmcgy.Reports.YearlyIncomeExpenseReport
  alias WmcgySchema.{Category, Transaction}

  # ===========================================================================
  # Category specific functions
  # ===========================================================================
  @spec list_categories(user :: User.t()) :: list(Category.t())
  defdelegate list_categories(user), to: Wmcgy.Categories

  @spec get_category!(user :: User.t(), id :: pos_integer) :: Category.t()
  defdelegate get_category!(user, id), to: Wmcgy.Categories

  @spec create_category(user :: User.t(), name :: String.t()) ::
          {:ok, Category.t()} | {:error, Ecto.Changeset.t()}
  defdelegate create_category(user, category_name), to: Wmcgy.Categories

  @spec update_category(category :: Category.t(), category_name :: String.t()) ::
          {:ok, Category.t()} | {:error, Ecto.Changeset.t()}
  defdelegate update_category(category, name), to: Wmcgy.Categories

  @spec delete_category(user :: User.t(), id :: pos_integer) ::
          {:ok, Category.t()} | {:error, Ecto.Changeset.t()}
  defdelegate delete_category(user, id), to: Wmcgy.Categories

  @spec has_categories?(user :: User.t()) :: boolean()
  defdelegate has_categories?(user), to: Wmcgy.Categories

  # ===========================================================================
  # Transaction specific functions
  # ===========================================================================
  @type sort_dir :: :desc | :asc
  @type transaction_sort_fields :: :date | :category | :description | :amount

  @type transaction_list_opts ::
          {:page, pos_integer()}
          | {:page_size, pos_integer()}
          | {:sort_field, transaction_sort_fields}
          | {:sort_dir, sort_dir}
  @spec list_transactions(user :: User.t(), opts :: list(transaction_list_opts)) ::
          Scrivener.Page.t(%{
            entries: list(Transaction.t()),
            page_number: pos_integer(),
            page_size: pos_integer(),
            total_entries: pos_integer(),
            total_pages: pos_integer()
          })
  defdelegate list_transactions(user, opts \\ []), to: Wmcgy.Transactions

  @spec list_transactions_for_export(user :: User.t()) :: list(Transaction.t())
  defdelegate list_transactions_for_export(user), to: Wmcgy.Transactions

  @spec get_transaction!(user :: User.t(), id :: pos_integer()) ::
          Transaction.t() | Ecto.NoResultsError
  defdelegate get_transaction!(user, id), to: Wmcgy.Transactions

  @type transaction_type :: :income | :expense
  @spec create_transaction(
          user :: User.t(),
          attrs :: %{
            description: String.t(),
            date: Date.t(),
            amount: Decimal.t(),
            type: transaction_type,
            category_id: pos_integer()
          }
        ) :: {:ok, Transaction.t()} | {:error, Ecto.Changeset.t()}
  defdelegate create_transaction(user, attrs), to: Wmcgy.Transactions

  @spec update_transaction(
          transaction :: Transaction.t(),
          attrs :: %{
            description: String.t(),
            date: Date.t(),
            amount: Decimal.t(),
            type: transaction_type,
            category_id: pos_integer()
          }
        ) :: {:ok, Transaction.t()} | {:error, Ecto.Changeset.t()}
  defdelegate update_transaction(transaction, attrs), to: Wmcgy.Transactions

  @spec delete_transaction(user :: User.t(), id :: pos_integer) ::
          {:ok, Transaction.t()} | {:error, Ecto.Changeset.t()}
  defdelegate delete_transaction(user, id), to: Wmcgy.Transactions

  @spec years_with_transactions(user :: User.t()) :: list(pos_integer())
  defdelegate years_with_transactions(user), to: Wmcgy.Transactions

  @spec import_transactions(
          import_progress :: Wmcgy.TransactionImport.ImportProgress,
          user :: User.t(),
          csv_header :: list(String.t()),
          transaction_data_rows :: list(list(String.t()))
        ) :: Wmcgy.TransactionImport.ImportProgress
  defdelegate import_transactions(import_progress, user, csv_header, transaction_data_rows),
    to: Wmcgy.TransactionImport

  # ===========================================================================
  # Report specific functionality
  # ===========================================================================
  @type income_expense_report_opts :: {:start_date, Date.t()} | {:end_date, Date.t()}
  @spec income_by_category_report(user :: User.t(), opts :: list(income_expense_report_opts)) ::
          CategoryReport.t()
  defdelegate income_by_category_report(user, opts \\ []), to: Wmcgy.Reports

  @spec expense_by_category_report(user :: User.t(), opts :: list(income_expense_report_opts)) ::
          CategoryReport.t()
  defdelegate expense_by_category_report(user, opts \\ []), to: Wmcgy.Reports

  @spec monthly_income_expense_report(
          user :: User.t(),
          start_year :: pos_integer(),
          start_month :: pos_integer(),
          end_year :: pos_integer,
          end_month :: pos_integer()
        ) :: MonthlyIncomeExpenseReport.t()
  defdelegate monthly_income_expense_report(user, start_year, start_month, end_year, end_month),
    to: Wmcgy.Reports

  @spec yearly_income_expense_report(
          user :: User.t(),
          start_year :: pos_integer(),
          end_year :: pos_integer()
        ) :: YearlyIncomeExpenseReport.t()
  defdelegate yearly_income_expense_report(user, start_year, end_year), to: Wmcgy.Reports

  @spec profit_for_month(user :: User.t(), year :: pos_integer, month :: pos_integer) ::
          Decimal.t()
  defdelegate profit_for_month(user, year, month), to: Wmcgy.Reports

  @spec profit_for_year(user :: User.t(), year :: pos_integer()) :: Decimal.t()
  defdelegate profit_for_year(user, year), to: Wmcgy.Reports
end
