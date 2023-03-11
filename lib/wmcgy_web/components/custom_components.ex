defmodule WmcgyWeb.CustomComponents do
  @moduledoc """
  Provides custom UI components.
  """

  use Phoenix.Component

  # ===========================================================================
  @doc """
  Renders the logo.
  ## Examples
    <.logo />
  """
  def logo(assigns) do
    ~H"""
    <div class="text-center text-emerald-500 ml-2 font-semi-bold text-5xl font-lobster">Wmcgy</div>
    """
  end

  # ===========================================================================
  @doc """
  Renders a styled page header.
  ## Examples
    <.page_header_title>Transactions</.page_title_title>
  """
  def page_header_title(assigns) do
    ~H"""
    <h1 class="text-3xl font-extrabold text-zinc-900">
      <%= render_slot(@inner_block) %>
    </h1>
    """
  end

  # ===========================================================================
  @doc """
  Renders a table.
  ## Examples
  <.custom_table id="users" rows={@users}>
    <:col :let={user} label="id" col_width="w-2/5"><%= user.id %></:col>
    <:col :let={user} label="username" col_width="w-2/5"><%= user.username %></:col>
    <:col label="Edit" sr_only={true} col_width="w-1/5">
  </.custom_table>
  """
  attr :id, :string, required: true
  attr :rows, :list, required: true

  slot :col, required: true do
    attr :label, :string
    attr :col_width, :string
    attr :sr_only, :boolean
  end

  def custom_table(assigns) do
    ~H"""
    <div id={@id} class="flex flex-col mt-4">
      <div class="-my-2 overflow-x-auto sm:-mx-6 lg:-mx-8">
        <div class="py-2 align-middle inline-block min-w-full sm:px-6 lg:px-8">
          <div class="shadow overflow-hidden border-b border-gray-200 sm:rounded-lg">
            <table class="table-fixed min-w-full divide-y divide-gray-200">
              <thead class="bg-gray-50">
                <tr>
                  <%= for col <- @col do %>
                    <.table_column col={col} />
                  <% end %>
                </tr>
              </thead>
              <tbody>
                <%= for {row, row_index} <- Enum.with_index @rows do %>
                  <tr
                    id={"#{@id}-row-#{Map.get(row, :id, row_index)}"}
                    class={if rem(row_index, 2) == 0, do: "bg-white", else: "bg-gray-50"}
                  >
                    <%= for {col, col_index} <- Enum.with_index @col do %>
                      <td
                        id={"#{@id}-row-#{Map.get(row, :id, row_index)}-col-#{col_index}"}
                        class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900"
                      >
                        <%= render_slot(col, row) %>
                      </td>
                    <% end %>
                  </tr>
                <% end %>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
    """
  end

  # ===========================================================================
  defp table_column(%{col: %{sr_only: true}} = assigns) do
    ~H"""
    <th scope="col" class={"#{@col[:col_width]} relative px-6 py-3"}>
      <span class="sr-only"><%= @col.label %></span>
    </th>
    """
  end

  defp table_column(assigns) do
    ~H"""
    <th
      scope="col"
      class={"#{@col[:col_width]} px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"}
    >
      <%= @col.label %>
    </th>
    """
  end
end
