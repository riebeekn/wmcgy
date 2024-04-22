defmodule WmcgyWeb.TransactionLive.FormComponent do
  @moduledoc """
  Transaction form component
  """
  use WmcgyWeb, :live_component

  alias Ecto.Changeset
  alias WmcgySchema.Transaction
  alias WmcgyUtilities.Params

  # ===========================================================================
  @impl true
  def update(%{transaction: transaction} = assigns, socket) do
    changeset =
      transaction
      |> Changeset.cast(%{}, Params.Transaction.keys())
      |> maybe_abs_amount(transaction.amount)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  # ===========================================================================
  @impl true
  def handle_event(
        "save",
        %{"transaction" => transaction_params},
        %{assigns: %{action: :new, current_user: current_user}} = socket
      ) do
    transaction_params
    |> Params.Transaction.normalize_parameters(:new)
    |> case do
      {:ok, normalized_params} ->
        Wmcgy.create_transaction(current_user, normalized_params)
        |> case do
          {:ok, _transaction} ->
            {:noreply,
             socket
             |> put_flash(:info, "Transaction created")
             |> push_redirect(to: ~p"/transactions")}

          {:error, %Ecto.Changeset{} = changeset} ->
            {:noreply, assign_form(socket, changeset)}
        end

      {:error, %Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  # ===========================================================================
  @impl true
  def handle_event(
        "save",
        %{"transaction" => transaction_params},
        %{assigns: %{action: :edit, transaction: transaction}} = socket
      ) do
    transaction_params
    |> Params.Transaction.normalize_parameters(:edit)
    |> case do
      {:ok, normalized_params} ->
        Wmcgy.update_transaction(
          transaction,
          normalized_params
        )
        |> case do
          {:ok, _transaction} ->
            {:noreply,
             socket
             |> put_flash(:info, "Transaction updated")
             |> push_redirect(to: ~p"/transactions")}

          {:error, %Ecto.Changeset{} = changeset} ->
            {:noreply, assign_form(socket, changeset)}
        end

      {:error, %Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  # ===========================================================================
  # auto-recover on LV disconnect/reconnect
  # see: https://fly.io/phoenix-files/how-phoenix-liveview-form-auto-recovery-works
  @impl true
  def handle_event("validate", %{"transaction" => transaction_params}, socket) do
    changeset =
      %Transaction{}
      |> Changeset.cast(transaction_params, Params.Transaction.keys())

    {:noreply, assign_form(socket, changeset)}
  end

  # ===========================================================================
  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset, as: :transaction))
  end

  # ===========================================================================
  defp maybe_abs_amount(changeset, nil), do: changeset

  defp maybe_abs_amount(changeset, amount) do
    changeset
    |> Changeset.change(amount: amount |> Decimal.abs())
  end
end
