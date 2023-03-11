defmodule Wmcgy.Transactions do
  @moduledoc """
  Context module for transaction specific functionality
  """
  alias Ecto.Changeset
  alias Wmcgy.Accounts.User
  alias Wmcgy.Query
  alias Wmcgy.Repo
  alias WmcgySchema.{Category, Transaction}

  @default_sort_field :date
  @default_sort_dir :desc

  # ===========================================================================
  def list_transactions(%User{} = user, opts \\ []) do
    pagination_values = page_and_page_size_from_opts(opts)
    sort_field = Keyword.get(opts, :sort_field, @default_sort_field)
    sort_dir = Keyword.get(opts, :sort_dir, @default_sort_dir)

    user
    |> Query.Transaction.for_user()
    |> Query.Transaction.include_category()
    |> Query.Transaction.sort_by(sort_field, sort_dir)
    |> Repo.paginate(page: pagination_values.page, page_size: pagination_values.page_size)
  end

  # ===========================================================================
  @default_page 1
  @default_page_size 30

  defp page_and_page_size_from_opts(opts) do
    page = Keyword.get(opts, :page, @default_page) |> max(1)
    page_size = Keyword.get(opts, :page_size, @default_page_size) |> min(30)

    %{
      page: page,
      page_size: page_size
    }
  end

  # ===========================================================================
  def create_transaction(%User{} = user, %Category{} = category, attrs) do
    attrs = maybe_negate_amount(attrs)

    %Transaction{}
    |> Changeset.cast(attrs, [:description, :date, :amount, :is_expense?])
    |> Changeset.put_assoc(:user, user)
    |> Changeset.put_assoc(:category, category)
    |> Repo.insert()
  end

  # ===========================================================================
  defp maybe_negate_amount(%{is_expense?: true, amount: amount} = attrs) do
    if Decimal.gt?(amount, 0) do
      Map.put(attrs, :amount, Decimal.negate(amount))
    else
      attrs
    end
  end

  defp maybe_negate_amount(%{type: :income, amount: amount} = attrs) do
    if Decimal.lt?(amount, 0) do
      Map.put(attrs, :amount, Decimal.negate(amount))
    else
      attrs
    end
  end

  defp maybe_negate_amount(attrs), do: attrs
end
