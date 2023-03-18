defmodule WmcgyWeb.TransactionLive.New do
  @moduledoc """
  Live view for the transactions create page
  """
  use WmcgyWeb, :live_view

  alias WmcgySchema.Transaction
  alias WmcgyUtilities.DateHelpers

  # ===========================================================================
  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(page_title: "New Transaction")
     |> load_and_assign_categories()
     |> assign_transaction()}
  end

  # ===========================================================================
  @impl true
  def render(assigns) do
    ~H"""
    <.page_header_title>Add Transaction</.page_header_title>
    <.live_component
      id="transaction-form"
      module={WmcgyWeb.TransactionLive.FormComponent}
      transaction={@transaction}
      current_user={@current_user}
      categories={@categories}
      action={@live_action}
      submit_label="Add Transaction"
      submit_disable_label="Adding transaction..."
    />
    """
  end

  # ===========================================================================
  defp load_and_assign_categories(socket) do
    assign(socket, categories: Wmcgy.list_categories(socket.assigns.current_user))
  end

  # ===========================================================================
  defp assign_transaction(socket) do
    assign(socket, :transaction, %Transaction{
      date: socket.assigns.today |> DateHelpers.to_string(),
      type: :expense
    })
  end
end
