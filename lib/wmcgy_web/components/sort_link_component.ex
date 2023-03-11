defmodule WmcgyWeb.SortLinkComponent do
  @moduledoc """
  Sort link live component
  """
  use Phoenix.LiveComponent

  # ===========================================================================
  @impl true
  def render(assigns) do
    ~H"""
    <a href="#" phx-click="sort" phx-target={@myself} phx-value-sort_field={@sort_field} class="flex">
      <%= @label %>
      <%= if @current_sort_field == @sort_field do %>
        <span class="pl-2">
          <%= if @current_sort_dir == :desc do %>
            <WmcgyWeb.CoreComponents.icon name="hero-arrow-down" class="h-4 w-4 text-emerald-600" />
          <% else %>
            <WmcgyWeb.CoreComponents.icon name="hero-arrow-up" class="h-4 w-4 text-emerald-600" />
          <% end %>
        </span>
      <% end %>
    </a>
    """
  end

  # ===========================================================================
  @impl true
  def handle_event("sort", %{"sort_field" => sort_field}, socket) do
    send(
      self(),
      {socket.assigns.data_changed_event_msg_key,
       %{
         sort_field: sort_field,
         sort_dir: flip_sort_dir(socket.assigns.current_sort_dir)
       }}
    )

    {:noreply, socket}
  end

  # ===========================================================================
  def parse_sort_field_param(params, default_sort_field, valid_sort_fields) do
    if params["sort_field"] in valid_sort_fields do
      String.to_existing_atom(params["sort_field"])
    else
      default_sort_field
    end
  end

  # ===========================================================================
  @default_sort_dir :desc
  def parse_sort_dir_param(params) do
    if params["sort_dir"] in ["asc", "desc"] do
      String.to_existing_atom(params["sort_dir"])
    else
      @default_sort_dir
    end
  end

  # ===========================================================================
  defp flip_sort_dir(:desc), do: :asc
  defp flip_sort_dir(:asc), do: :desc
end
