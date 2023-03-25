defmodule WmcgyWeb.Components.MtdYtdWidget do
  @moduledoc """
  Mtd / Ytd component
  """
  use WmcgyWeb, :live_component

  alias Number.Currency

  # ===========================================================================
  @impl true
  def mount(socket) do
    {:ok, assign(socket, mtd: "", ytd: "")}
  end

  # ===========================================================================
  @impl true
  def render(assigns) do
    ~H"""
    <div class="my-4 sm:my-0 bg-white rounded-lg shadow-md p-4 max-w-xs sm:max-w-sm">
      <h3 class="font-semibold text-emerald-800">Current income versus expenses</h3>
      <div id="mtd">
        <span class="text-gray-500 tracking-wide">MTD: </span><span class={"font-medium #{highlight_if_loss(@mtd || "")}"}><%= @mtd |> maybe_to_currency() %></span>
      </div>
      <div id="ytd">
        <span class="text-gray-500 tracking-wide">YTD: </span><span class={"font-medium #{highlight_if_loss(@ytd || "")}"}><%= @ytd |> maybe_to_currency() %></span>
      </div>
    </div>
    """
  end

  # ===========================================================================
  @impl true
  def update(%{today: nil} = assigns, socket) do
    socket =
      socket
      |> assign(assigns)

    {:ok, socket}
  end

  # ===========================================================================
  @impl true
  def update(%{today: today, current_user: current_user} = assigns, socket) do
    mtd = Wmcgy.profit_for_month(current_user, today.year, today.month)
    ytd = Wmcgy.profit_for_year(current_user, today.year)

    socket =
      socket
      |> assign(assigns)
      |> assign(:mtd, mtd)
      |> assign(:ytd, ytd)

    {:ok, socket}
  end

  # ===========================================================================
  defp maybe_to_currency(""), do: ""
  defp maybe_to_currency(val), do: Currency.number_to_currency(val)
end
