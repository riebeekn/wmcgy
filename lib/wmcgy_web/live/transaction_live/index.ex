defmodule WmcgyWeb.TransactionLive.Index do
  use WmcgyWeb, :live_view

  alias Number.Currency
  alias WmcgyUtilities.DateHelpers
  alias WmcgyWeb.SortLinkComponent

  # ===========================================================================
  @impl true
  def mount(_params, _session, %{assigns: %{current_user: current_user}} = socket) do
    transactions = Wmcgy.list_transactions(current_user)
    {:ok, assign(socket, transactions: transactions)}
  end

  # ===========================================================================
  @default_sort_field :date
  @valid_sort_fields ["date", "category", "description", "amount"]
  @impl true
  def handle_params(params, _url, socket) do
    sort_field =
      SortLinkComponent.parse_sort_field_param(params, @default_sort_field, @valid_sort_fields)

    sort_dir = SortLinkComponent.parse_sort_dir_param(params)

    {:noreply,
     socket
     |> assign_transactions(sort_field, sort_dir)
     |> assign(:current_sort_field, sort_field)
     |> assign(:current_sort_dir, sort_dir)}
  end

  # ===========================================================================
  @impl true
  def handle_info(
        {:transactions_data_changed, %{sort_field: sort_field, sort_dir: sort_dir}},
        socket
      ) do
    {:noreply,
     push_patch(socket,
       to: ~p"/transactions?sort_field=#{sort_field}&sort_dir=#{sort_dir}"
     )}
  end

  # ===========================================================================
  defp assign_transactions(
         %{assigns: %{current_user: current_user}} = socket,
         sort_field,
         sort_dir
       ) do
    transactions =
      Wmcgy.list_transactions(current_user,
        page: 1,
        page_size: 30,
        sort_field: sort_field,
        sort_dir: sort_dir
      )

    socket
    |> assign(:transactions, transactions.entries)
    |> assign(:total_pages, transactions.total_pages)
    |> assign(:total_entries, transactions.total_entries)
  end
end
