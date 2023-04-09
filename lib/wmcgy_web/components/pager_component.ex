defmodule WmcgyWeb.PagerComponent do
  @moduledoc """
  Pager live component
  """
  use Phoenix.LiveComponent

  # ===========================================================================
  @impl true
  def render(assigns) do
    ~H"""
    <div id={@id} class="pt-6 sm:flex items-center justify-between">
      <div class="flex-1 flex justify-between">
        <span class="relative z-0 inline-flex shadow-sm rounded-md">
          <button
            phx-click="previous_page"
            phx-target={@myself}
            type="button"
            class="relative inline-flex items-center px-2 py-2 rounded-l-md border border-zinc-300 bg-white text-sm font-medium text-zinc-500 hover:bg-zinc-50 focus:z-10 focus:outline-none focus:ring-1 focus:ring-emerald-600 focus:border-emerald-600"
          >
            <span class="sr-only">Previous</span>
            <WmcgyWeb.CoreComponents.icon
              name="hero-arrow-long-left"
              class="mr-1 h-5 w-5 text-zinc-400"
            /> Prev
          </button>
          <button
            phx-click="next_page"
            phx-target={@myself}
            type="button"
            class="-ml-px relative inline-flex items-center px-2 py-2 rounded-r-md border border-zinc-300 bg-white text-sm font-medium text-zinc-500 hover:bg-zinc-50 focus:z-10 focus:outline-none focus:ring-1 focus:ring-emerald-600 focus:border-emerald-600"
          >
            <span class="sr-only">Next</span>
            Next
            <WmcgyWeb.CoreComponents.icon
              name="hero-arrow-long-right"
              class="ml-1 h-5 w-5 text-zinc-400"
            />
          </button>
        </span>
      </div>
      <div class="flex mt-2 sm:mt-0 sm:justify-end">
        <div>
          <p class="text-sm text-zinc-700">
            Showing
            <span class="font-medium">
              <%= first_item_being_displayed(
                @current_page,
                @current_page_size,
                @total_pages,
                @total_entries
              ) %>
            </span>
            to
            <span class="font-medium">
              <%= last_item_being_displayed(@current_page, @current_page_size, @total_entries) %>
            </span>
            of <span class="font-medium"><%= @total_entries %></span>
            results
          </p>
        </div>
      </div>
    </div>
    """
  end

  # ===========================================================================
  @impl true
  def handle_event("previous_page", _params, socket) do
    page = calculate_previous_page_number(socket.assigns.current_page)

    send(
      self(),
      {socket.assigns.data_changed_event_msg_key,
       %{page: page, page_size: socket.assigns.current_page_size}}
    )

    {:noreply, socket}
  end

  # ===========================================================================
  @impl true
  def handle_event("next_page", _params, socket) do
    page = calculate_next_page_number(socket.assigns.current_page, socket.assigns.total_pages)

    send(
      self(),
      {socket.assigns.data_changed_event_msg_key,
       %{page: page, page_size: socket.assigns.current_page_size}}
    )

    {:noreply, socket}
  end

  # ===========================================================================
  @default_page "1"
  def parse_page_param(params) do
    params
    |> Map.get("page", @default_page)
    |> Integer.parse()
    |> case do
      :error -> String.to_integer(@default_page)
      {page, _remainder} -> max(page, 1)
    end
  end

  # ===========================================================================
  @default_page_size "30"
  def parse_page_size_param(params) do
    params
    |> Map.get("page_size", @default_page_size)
    |> Integer.parse()
    |> case do
      :error -> String.to_integer(@default_page_size)
      {page, _remainder} -> page
    end
  end

  # ===========================================================================
  defp calculate_previous_page_number(current_page) when current_page <= 1, do: 1
  defp calculate_previous_page_number(current_page), do: current_page - 1

  # ===========================================================================
  defp calculate_next_page_number(current_page, total_pages) do
    if current_page < total_pages do
      current_page + 1
    else
      current_page
    end
  end

  # ===========================================================================
  defp first_item_being_displayed(page, _, _, _) when page <= 1, do: 1

  defp first_item_being_displayed(page, page_size, total_pages, total_entries)
       when page > total_pages do
    total_entries - number_of_items_on_last_page(total_entries, page_size) + 1
  end

  defp first_item_being_displayed(page, page_size, _, _), do: (page - 1) * page_size + 1

  defp number_of_items_on_last_page(total_entries, page_size) do
    total_entries
    |> rem(page_size)
    |> case do
      0 -> page_size
      number_of_items -> number_of_items
    end
  end

  # ===========================================================================
  defp last_item_being_displayed(page, page_size, total_entries) when page <= 1,
    do: min(page_size, total_entries)

  defp last_item_being_displayed(page, page_size, total_entries),
    do: min(page * page_size, total_entries)
end
