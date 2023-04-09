defmodule WmcgyWeb.TransactionLive.Import do
  @moduledoc """
  Live view for the transactions import page
  """
  use WmcgyWeb, :live_view

  alias NimbleCSV.RFC4180, as: CSV
  alias Wmcgy.TransactionImport.ImportProgress

  # ===========================================================================
  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(
       uploaded_files: [],
       import_progress: nil,
       import_status: :resting,
       page_title: "Import Transactions"
     )
     |> allow_upload(:transaction_data, accept: ~w(.txt .csv), max_entries: 1)}
  end

  # ===========================================================================
  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  # ===========================================================================
  @chunk_size 100
  @impl true
  def handle_event("import", _params, socket) do
    consume_uploaded_entries(socket, :transaction_data, fn %{path: path}, _entry ->
      # grab the CSV header
      header =
        path
        |> File.stream!()
        |> CSV.parse_stream(skip_headers: false)
        |> Enum.fetch!(0)

      # grab the first chunk to process
      {first_chunk, rest} =
        path
        |> File.stream!()
        |> CSV.parse_stream()
        |> Enum.split(@chunk_size)

      # send a message to process the first chunk
      send(self(), {:import_chunk, header, first_chunk, rest})

      # return an :ok tuple as this is what consume_uploaded_entries expects
      {:ok, :importing}
    end)

    {:noreply,
     assign(socket,
       import_progress: %ImportProgress{},
       import_status: :importing
     )}
  end

  # ===========================================================================
  @impl true
  def handle_info({:import_chunk, header, current_chunk, rest}, socket) do
    import_progress = import_current_chunk(socket, header, current_chunk)

    cond do
      import_progress.invalid_file? ->
        {:noreply, assign(socket, import_progress: import_progress, import_status: :bad_file)}

      rest == [] ->
        {:noreply, assign(socket, import_progress: import_progress, import_status: :resting)}

      true ->
        # grab the next chunk
        {next_chunk, rest} = Enum.split(rest, @chunk_size)
        # send a message to process the next chunk
        send(self(), {:import_chunk, header, next_chunk, rest})

        {:noreply, assign(socket, import_progress: import_progress)}
    end
  end

  # ===========================================================================
  defp import_current_chunk(
         %{assigns: %{current_user: current_user}} = socket,
         header,
         current_chunk
       ) do
    Wmcgy.import_transactions(
      socket.assigns.import_progress,
      current_user,
      header,
      current_chunk
    )
  end

  # ===========================================================================
  defp status_text(:importing), do: "Processing transaction import... please wait"
  defp status_text(:resting), do: "Import complete"
  defp status_text(:bad_file), do: "Sorry that is an invalid file, nothing imported!"

  # ===========================================================================
  defp percentage(current_row, _) when current_row <= 1, do: 0.0

  defp percentage(current_row, count) do
    (count / (current_row - 1) * 100.0) |> Float.round(2)
  end

  # ===========================================================================
  attr :count, :integer
  attr :percentage, :float
  attr :role, :string
  attr :style, :atom, default: :success
  attr :title, :string

  defp import_card(assigns) do
    ~H"""
    <div class="px-4 py-5 sm:p-6" data-role={@role}>
      <dt class="text-base font-normal text-zinc-900"><%= @title %></dt>
      <dd class="mt-1 flex items-baseline justify-between md:block lg:flex">
        <div class={"flex items-center text-2xl font-semibold #{import_card_primary_text_color(@style)}"}>
          <%= @count %>
          <div class={"ml-2 inline-flex items-baseline px-2.5 py-0.5 rounded-full text-sm font-medium #{import_card_bg_color(@style)} #{import_card_secondary_text_color(@style)} md:mt-2 lg:mt-0"}>
            <%= @percentage %>%
          </div>
        </div>
      </dd>
    </div>
    """
  end

  defp import_card_primary_text_color(:success), do: "text-emerald-600"
  defp import_card_primary_text_color(:failure), do: "text-red-700"
  defp import_card_secondary_text_color(:success), do: "text-emerald-800"
  defp import_card_secondary_text_color(:failure), do: "text-red-800"
  defp import_card_bg_color(:success), do: "bg-emerald-100"
  defp import_card_bg_color(:failure), do: "bg-red-100"
end
