defmodule WmcgyWeb.TransactionLive.Index do
  use WmcgyWeb, :live_view

  alias Number.Currency
  alias WmcgyUtilities.DateHelpers

  # ===========================================================================
  @impl true
  def mount(_params, _session, %{assigns: %{current_user: current_user}} = socket) do
    transactions = Wmcgy.list_transactions(current_user)
    {:ok, assign(socket, transactions: transactions)}
  end
end
