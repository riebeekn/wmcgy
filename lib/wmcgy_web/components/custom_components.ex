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
    <.page_header_title>Transactions</.page_header_title>
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
  Renders a cta section

  ## Examples
    <.cta>Some CTA!</.cta>
  """
  slot :inner_block, required: true
  slot :subtitle
  slot :actions

  def cta(assigns) do
    ~H"""
    <div class="bg-emerald-200">
      <div class="max-w-7xl mx-auto py-12 px-4 sm:px-6 lg:py-24 lg:px-8">
        <h2 class="text-3xl space-y-1 font-extrabold tracking-tight text-gray-900 md:text-4xl">
          <span class="block">
            <%= render_slot(@inner_block) %>
          </span>
          <span :if={@subtitle != []} class="block text-emerald-600">
            <%= render_slot(@subtitle) %>
          </span>
        </h2>
        <div :if={@actions != []} class="mt-4">
          <%= render_slot(@actions) %>
        </div>
      </div>
    </div>
    """
  end

  # ===========================================================================
  @doc """
  Renders a chart

  ## Examples
    <.chart
      id="expense-chart"
      type="pie"
      title="Expenses"
      data_changed_event={:expense_chart_update}
    />
  """
  attr :id, :string, required: true
  attr :title, :string, required: true
  attr :type, :string, required: true
  attr :data_changed_event, :atom, default: nil

  def chart(assigns) do
    assigns =
      assigns
      |> assign_new(:chart_data, fn -> [] end)
      |> assign(:hook, hook_from_type(assigns))

    ~H"""
    <div>
      <h3 class="text-lg font-medium text-gray-900"><%= @title %></h3>
      <canvas
        id={@id}
        phx-hook={@hook}
        phx-update="ignore"
        data-changed-event={@data_changed_event}
        data-chart-data={Jason.encode!(@chart_data)}
        class="max-w-lg"
      >
      </canvas>
    </div>
    """
  end

  defp hook_from_type(%{type: "pie"}), do: "PieChart"
  defp hook_from_type(%{type: "bar"}), do: "BarChart"
  defp hook_from_type(%{type: "line"}), do: "LineChart"

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
  attr :include_footer?, :boolean, default: false
  attr :paginate?, :boolean, default: false
  attr :current_page, :integer, default: nil
  attr :current_page_size, :integer, default: nil
  attr :total_pages, :integer, default: nil
  attr :total_entries, :integer, default: nil
  attr :current_sort_field, :string, default: nil
  attr :current_sort_dir, :atom, default: nil
  attr :data_changed_event_msg_key, :atom, default: nil

  slot :col, required: true do
    attr :label, :string
    attr :col_width, :string
    attr :sr_only, :boolean
    attr :sort_field, :atom
  end

  slot :footer_col

  def custom_table(assigns) do
    ~H"""
    <%= if @paginate? do %>
      <.live_component
        module={WmcgyWeb.PagerComponent}
        id={"#{@id}-top-pager"}
        current_page={@current_page}
        current_page_size={@current_page_size}
        total_pages={@total_pages}
        total_entries={@total_entries}
        data_changed_event_msg_key={@data_changed_event_msg_key}
      />
    <% end %>
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
              <%= if @include_footer? do %>
                <tfoot class="bg-emerald-50">
                  <tr>
                    <%= for {fcol, f_index} <- Enum.with_index @footer_col do %>
                      <td
                        id={"#{@id}-footer-col-#{f_index}"}
                        class="px-6 py-4 whitespace-nowrap text-sm font-bold text-gray-900 uppercase"
                      >
                        <%= render_slot(fcol) %>
                      </td>
                    <% end %>
                  </tr>
                </tfoot>
              <% end %>
            </table>
          </div>
        </div>
      </div>
    </div>
    <%= if @paginate? do %>
      <.live_component
        module={WmcgyWeb.PagerComponent}
        id={"#{@id}-bottom-pager"}
        current_page={@current_page}
        current_page_size={@current_page_size}
        total_pages={@total_pages}
        total_entries={@total_entries}
        data_changed_event_msg_key={@data_changed_event_msg_key}
      />
    <% end %>
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
