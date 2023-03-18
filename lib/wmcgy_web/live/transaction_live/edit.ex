defmodule WmcgyWeb.TransactionLive.Edit do
  @moduledoc """
  Live view for the transactions edit page
  """
  use WmcgyWeb, :live_view

  alias WmcgyUtilities.DateHelpers

  # ===========================================================================
  @impl true
  def mount(
        %{"id" => transaction_id},
        _session,
        %{assigns: %{current_user: current_user}} = socket
      ) do
    transaction = Wmcgy.get_transaction!(current_user, transaction_id)

    {:ok,
     socket
     |> assign(page_title: "Edit Transaction")
     |> load_and_assign_categories()
     |> assign_transaction(transaction)}
  end

  # ===========================================================================
  @impl true
  def render(assigns) do
    ~H"""
    <.page_header_title>Edit Transaction</.page_header_title>
    <.live_component
      id="transaction-form"
      module={WmcgyWeb.TransactionLive.FormComponent}
      transaction={@transaction}
      current_user={@current_user}
      categories={@categories}
      action={@live_action}
      submit_label="Edit Transaction"
      submit_disable_label="Updating transaction..."
    />
    """
  end

  # ===========================================================================
  defp load_and_assign_categories(socket) do
    assign(socket, categories: Wmcgy.list_categories(socket.assigns.current_user))
  end

  # ===========================================================================
  defp assign_transaction(socket, transaction) do
    assign(
      socket,
      :transaction,
      Map.put(transaction, :date, transaction.date |> DateHelpers.to_string())
    )
  end
end
