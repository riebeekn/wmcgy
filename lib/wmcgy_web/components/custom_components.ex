defmodule WmcgyWeb.CustomComponents do
  @moduledoc """
  Provides custom UI components.
  """

  use Phoenix.Component

  # ===========================================================================
  @doc """
  Renders a flex container.
  ## Examples
  <.flex_container>
    <div>Some item</div>
    <div>Some other item</div>
  </.flex_container>
  """
  def flex_container(assigns) do
    ~H"""
    <div class="sm:flex justify-between items-center border-b-2 border-gray-100 pt-6 md:space-x-10">
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

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
  attr :current_sort_field, :string, default: nil
  attr :current_sort_dir, :atom, default: nil
  attr :data_changed_event_msg_key, :atom, default: nil

  slot :col, required: true do
    attr :label, :string
    attr :col_width, :string
    attr :sr_only, :boolean
    attr :sort_field, :atom
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
                    <.table_column_header
                      col={col}
                      table_id={@id}
                      current_sort_field={@current_sort_field}
                      current_sort_dir={@current_sort_dir}
                      data_changed_event_msg_key={@data_changed_event_msg_key}
                    />
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
  # sr_only table column header
  defp table_column_header(%{col: %{sr_only: true}} = assigns) do
    ~H"""
    <th scope="col" class={"#{@col[:col_width]} relative px-6 py-3"}>
      <span class="sr-only"><%= @col.label %></span>
    </th>
    """
  end

  # sortable table column header
  defp table_column_header(%{col: %{sort_field: _sort_field}} = assigns) do
    ~H"""
    <th
      scope="col"
      class={"#{@col[:col_width]} px-6 py-3 text-left text-xs font-semibold text-emerald-700 uppercase tracking-wider hover:text-emerald-600"}
    >
      <.live_component
        module={WmcgyWeb.SortLinkComponent}
        id={"#{@table_id}-#{@col.sort_field}-sort-link"}
        label={@col.label}
        sort_field={@col.sort_field}
        current_sort_field={@current_sort_field}
        current_sort_dir={@current_sort_dir}
        data_changed_event_msg_key={@data_changed_event_msg_key}
      />
    </th>
    """
  end

  # default table column header
  defp table_column_header(assigns) do
    ~H"""
    <th
      scope="col"
      class={"#{@col[:col_width]} px-6 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider"}
    >
      <%= @col.label %>
    </th>
    """
  end
end
