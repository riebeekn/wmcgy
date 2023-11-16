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
    <div class="sm:flex justify-between items-center border-b-2 border-zinc-100 pt-6 md:space-x-10">
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  # ===========================================================================
  @doc """
  Renders a stats section.
  ## Examples
  <.stats_container columns={3}>
    <:stat label="Total Income" value="$12" />
    <:stat label="Total Expenses" value="$14" text_color="text-red-700" />
  </.stats_container>
  """
  attr :columns, :integer, required: true

  slot :stat, required: true do
    attr :label, :string
    attr :value, :string
    attr :text_color, :string
  end

  def stats_container(assigns) do
    ~H"""
    <div>
      <dl class={"mt-4 grid grid-cols-1 gap-5 md:grid-cols-#{@columns}"}>
        <%= for stat <- @stat do %>
          <div class="bg-white px-4 py-5 sm:p-6">
            <dt class="truncate text-sm font-semibold text-zinc-900"><%= stat.label %></dt>
            <dd class={"mt-1 text-3xl font-semibold tracking-tight #{Map.get(stat, :text_color, "text-zinc-900")}"}>
              <%= stat.value %>
            </dd>
          </div>
        <% end %>
      </dl>
    </div>
    """
  end

  # ===========================================================================
  @doc """
  Renders the logo.
  ## Examples
    <.logo />
  """
  attr :color, :string, default: "text-emerald-600"

  def logo(assigns) do
    ~H"""
    <div class={"text-center #{@color} ml-2 font-semi-bold text-5xl font-lobster"}>Wmcgy</div>
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
        <h2 class="text-3xl space-y-1 font-extrabold tracking-tight text-zinc-900 md:text-4xl">
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

  def chart(%{type: "pie"} = assigns) do
    assigns =
      assigns
      |> assign_new(:chart_data, fn -> [] end)
      |> assign(:hook, hook_from_type(assigns))

    ~H"""
    <.chart_title title={@title} />
    <div class="flex justify-center">
      <div>
        <canvas
          id={@id}
          phx-hook={@hook}
          phx-update="ignore"
          data-changed-event={@data_changed_event}
          data-chart-data={Jason.encode!(@chart_data)}
        >
        </canvas>
      </div>
    </div>
    """
  end

  def chart(assigns) do
    assigns =
      assigns
      |> assign_new(:chart_data, fn -> [] end)
      |> assign(:hook, hook_from_type(assigns))

    ~H"""
    <.chart_title title={@title} />
    <div class="sm:p-2">
      <canvas
        id={@id}
        phx-hook={@hook}
        phx-update="ignore"
        data-changed-event={@data_changed_event}
        data-chart-data={Jason.encode!(@chart_data)}
      >
      </canvas>
    </div>
    """
  end

  defp chart_title(assigns) do
    ~H"""
    <h3 class="mt-4 ml-6 truncate text-sm font-semibold text-zinc-900"><%= @title %></h3>
    """
  end

  defp hook_from_type(%{type: "pie"}), do: "PieChart"
  defp hook_from_type(%{type: "bar"}), do: "BarChart"
  defp hook_from_type(%{type: "line"}), do: "LineChart"

  # ===========================================================================
  @doc """
  Renders a spinner with an optional message

  ## Examples
    <.spinner message="Importing..." animate?={true} />
  """
  attr :animate?, :boolean, default: false
  attr :message, :string, default: ""

  def spinner(assigns) do
    ~H"""
    <div class="flex justify-center text-2xl text-emerald-700 pt-12" data-role="spinner-text">
      <%= @message %>
    </div>
    <div class="flex items-center justify-center pt-2">
      <WmcgyWeb.CoreComponents.icon
        name="hero-cog-8-tooth"
        class={"h-16 w-16 text-emerald-500 #{if @animate?, do: "animate-spin", else: ""}"}
      />
    </div>
    """
  end

  # ===========================================================================
  @doc """
  Renders a file upload dialog

  ## Examples
    <.file_upload uploads={@uploads} />
  """
  attr :uploads, :any, required: true

  def file_upload(assigns) do
    ~H"""
    <%= for {_ref, err} <- @uploads.transaction_data.errors do %>
      <div class="rounded-md bg-red-100 p-4 mb-4">
        <p data-role="validation-error" class="text-sm font-medium text-red-800">
          <%= friendly_error(err) %>
        </p>
      </div>
    <% end %>
    <!-- upload dialog -->
    <div
      phx-drop-target={@uploads.transaction_data.ref}
      class="sm:grid sm:grid-cols-3 sm:gap-4 sm:items-start sm:pt-5"
    >
      <div class="mt-1 sm:mt-0 sm:col-span-2">
        <div class="max-w-2xl flex justify-center px-6 pt-5 pb-6 border-2 border-zinc-300 border-dashed rounded-md">
          <div class="space-y-1 text-center">
            <WmcgyWeb.CoreComponents.icon
              name="hero-document-arrow-up"
              class="mx-auto h-12 w-12 text-zinc-400"
            />

            <div class="flex text-sm text-zinc-600">
              <label
                for={@uploads.transaction_data.ref}
                class="relative cursor-pointer font-medium text-green-700 hover:text-green-600"
              >
                <span>Upload a file</span>
                <.live_file_input upload={@uploads.transaction_data} class="sr-only" />
                <input id="file-upload" name="file-upload" type="file" class="sr-only" />
              </label>
              <p class="pl-1">or drag and drop</p>
            </div>
            <p class="text-xs text-zinc-500">
              CSV, TXT up to 8MB
            </p>
          </div>
        </div>
      </div>
    </div>
    <!-- selected file -->
    <%= for entry <- @uploads.transaction_data.entries do %>
      <div data-role="file-path-preview" class="pt-3 flex text-sm font-medium">
        <div class="text-zinc-500">Selected file:</div>
        <div class="text-zinc-900 ml-2"><%= entry.client_name %></div>
      </div>
    <% end %>
    """
  end

  defp friendly_error(:too_large), do: "File too large, max file size is 8MB."
  defp friendly_error(:too_many_files), do: "Too many files."
  defp friendly_error(:not_accepted), do: "Unacceptable file type, only txt / csv allowed."

  # ===========================================================================
  @doc """
  Renders a data list.
  ## Examples

  <.data_list id="users" rows={@user}>
    <:list_item :let={user} style="text-sm font-medium text-gray-900">
      <%= user.name %>
    </:list_item>
  </.data_list>
  """
  attr :id, :string, required: true
  attr :rows, :list, required: true

  slot :list_item, required: true do
    attr :label, :string
    attr :style, :string
  end

  slot :footer_item do
    attr :style, :string
  end

  def data_list(assigns) do
    ~H"""
    <ul id={@id}>
      <%= for row <- @rows do %>
        <li class="px-4 pb-2">
          <hr class="h-px my-2 bg-gray-200 border-0 dark:bg-gray-700" />
          <%= for list_item <- @list_item do %>
            <p class={Map.get(list_item, :style, "text-sm text-gray-500")}>
              <%= Map.get(list_item, :label, "") %><%= render_slot(list_item, row) %>
            </p>
          <% end %>
        </li>
      <% end %>
      <li class="bg-emerald-50 px-4 py-2">
        <%= for footer_item <- @footer_item do %>
          <p class={Map.get(footer_item, :style, "text-sm text-gray-500")}>
            <%= render_slot(footer_item) %>
          </p>
        <% end %>
      </li>
    </ul>
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
          <div class="shadow overflow-hidden border-b border-zinc-200 sm:rounded-lg">
            <table class="table-fixed min-w-full divide-y divide-zinc-200">
              <thead class="bg-zinc-50">
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
                    class={if rem(row_index, 2) == 0, do: "bg-white", else: "bg-zinc-50"}
                  >
                    <%= for {col, col_index} <- Enum.with_index @col do %>
                      <td
                        id={"#{@id}-row-#{Map.get(row, :id, row_index)}-col-#{col_index}"}
                        class="px-6 py-4 whitespace-nowrap text-sm font-medium text-zinc-900"
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
                        class="px-6 py-4 whitespace-nowrap text-sm font-bold text-zinc-900 uppercase"
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
      class={"#{@col[:col_width]} px-6 py-3 text-left text-xs font-semibold text-zinc-500 uppercase tracking-wider"}
    >
      <%= @col.label %>
    </th>
    """
  end

  # ===========================================================================
  def highlight_if_loss(nil), do: ""
  def highlight_if_loss(""), do: ""

  def highlight_if_loss(val) do
    if Decimal.lt?(val, 0) do
      "text-red-700"
    else
      ""
    end
  end
end
