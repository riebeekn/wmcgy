defmodule WmcgyWeb.TransactionLive.Index do
  use WmcgyWeb, :live_view

  alias Number.Currency
  alias WmcgyUtilities.DateHelpers
  alias WmcgyWeb.{PagerComponent, SortLinkComponent}

  # ===========================================================================
  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  # ===========================================================================
  @default_sort_field :date
  @valid_sort_fields ["date", "category", "description", "amount"]
  @impl true
  def handle_params(params, _url, socket) do
    sort_field =
      SortLinkComponent.parse_sort_field_param(params, @default_sort_field, @valid_sort_fields)

    sort_dir = SortLinkComponent.parse_sort_dir_param(params)
    page = PagerComponent.parse_page_param(params)
    page_size = PagerComponent.parse_page_size_param(params)

    {:noreply,
     socket
     |> assign_transactions(page, page_size, sort_field, sort_dir)
     |> assign(:current_page, page)
     |> assign(:current_page_size, page_size)
     |> assign(:current_sort_field, sort_field)
     |> assign(:current_sort_dir, sort_dir)}
  end

  # ===========================================================================
  @impl true
  def handle_info({:transactions_data_changed, %{page: page, page_size: page_size}}, socket) do
    {:noreply,
     push_patch(socket,
       to:
         ~p"/transactions?sort_field=#{socket.assigns.current_sort_field}&sort_dir=#{socket.assigns.current_sort_dir}&page=#{page}&page_size=#{page_size}"
     )}
  end

  # ===========================================================================
  @impl true
  def handle_info(
        {:transactions_data_changed, %{sort_field: sort_field, sort_dir: sort_dir}},
        socket
      ) do
    {:noreply,
     push_patch(socket,
       to: ~p"/transactions?sort_field=#{sort_field}&sort_dir=#{sort_dir}&page=1&page_size=30"
     )}
  end

  # ===========================================================================
  defp assign_transactions(
         %{assigns: %{current_user: current_user}} = socket,
         page,
         page_size,
         sort_field,
         sort_dir
       ) do
    transactions =
      Wmcgy.list_transactions(current_user,
        page: page,
        page_size: page_size,
        sort_field: sort_field,
        sort_dir: sort_dir
      )

    socket
    |> assign(:transactions, transactions.entries)
    |> assign(:total_pages, transactions.total_pages)
    |> assign(:total_entries, transactions.total_entries)
  end
end
