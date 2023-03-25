defmodule Wmcgy.TransactionImport do
  @moduledoc """
  Module to perform transaction imports
  """
  alias Wmcgy.Accounts.User
  alias Wmcgy.Categories
  alias Wmcgy.Repo
  alias Wmcgy.TransactionImport.ImportProgress
  alias Wmcgy.Transactions

  alias WmcgyUtilities.Params

  # ===========================================================================
  def import_transactions(
        import_progress,
        %User{} = user,
        csv_header,
        transaction_data_rows
      ) do
    if valid_header?(csv_header) do
      transaction_data_rows
      |> Enum.reduce(import_progress, fn transaction_data_row, acc ->
        user
        |> maybe_import_row(transaction_data_row)
        |> ImportProgress.handle_event(acc)
      end)
    else
      %ImportProgress{invalid_file?: true}
    end
  end

  # ===========================================================================
  @expected_csv_header ["ID", "Date", "Category", "Description", "Amount"]
  defp valid_header?(csv_header), do: csv_header == @expected_csv_header

  # ===========================================================================
  @id_index 0
  @date_index 1
  @category_index 2
  @description_index 3
  @amount_index 4
  defp maybe_import_row(user, transaction_data_row) do
    Repo.transaction(fn ->
      category_name = Enum.at(transaction_data_row, @category_index)
      transaction_params = build_transaction_params_from_row(transaction_data_row)

      with {:ok, category} <- get_or_create_category(user, category_name),
           {:ok, _transaction, operation_performed_on_transaction} <-
             process_transaction(user, category, transaction_params) do
        operation_performed_on_transaction
      else
        {:error, error_changeset} ->
          Repo.rollback(error_changeset)
      end
    end)
  end

  # ===========================================================================
  defp build_transaction_params_from_row(transaction_data_row) do
    %{
      external_id: Enum.at(transaction_data_row, @id_index),
      date: Enum.at(transaction_data_row, @date_index),
      description:
        Enum.at(transaction_data_row, @description_index) |> maybe_default_description(),
      amount: Enum.at(transaction_data_row, @amount_index)
    }
  end

  # ===========================================================================
  defp maybe_default_description(""), do: "n/a"
  defp maybe_default_description(description), do: description

  # ===========================================================================
  defp get_or_create_category(user, name) do
    %{name: name}
    |> Params.Category.normalize_parameters(:new)
    |> case do
      {:ok, normalized_params} -> Categories.get_or_create_category(user, normalized_params.name)
      {:error, error_changeset} -> {:error, error_changeset}
    end
  end

  # ===========================================================================
  defp process_transaction(user, category, transaction_attrs) do
    transaction_attrs
    |> Map.put(:category_id, category.id)
    # we hard-code type to expense, it is set for real once amount is
    # casted successfully in normalized_params
    |> Map.put(:type, "expense")
    |> Params.Transaction.normalize_parameters(:new, include_external_id?: true)
    |> case do
      {:ok, normalized_params} ->
        normalized_params =
          normalized_params
          |> set_type_from_amount()

        user
        |> Transactions.create_or_maybe_update_transaction(normalized_params)

      {:error, error_cs} ->
        {:error, error_cs}
    end
  end

  # ===========================================================================
  defp set_type_from_amount(%{amount: amount} = params) do
    if Decimal.lt?(amount, 0) do
      Map.put(params, :type, :expense)
    else
      Map.put(params, :type, :income)
    end
  end
end
