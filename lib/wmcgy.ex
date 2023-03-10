defmodule Wmcgy do
  @moduledoc """
  API for the application, all calls from the front-end should go thru
  this module vs directly calling into individual context modules.
  """
  use Boundary, deps: [WmcgySchema], exports: [Accounts, Accounts.User]

  alias Wmcgy.Accounts.User
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
end
