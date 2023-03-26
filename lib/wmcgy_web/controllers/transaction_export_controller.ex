defmodule WmcgyWeb.TransactionExportController do
  use WmcgyWeb, :controller

  alias NimbleCSV.RFC4180, as: CSV

  @header ["ID", "Date", "Category", "Description", "Amount"]

  def create(conn, _params) do
    user = conn.assigns.current_user

    transaction_data =
      user
      |> Wmcgy.list_transactions_for_export()
      |> Enum.map(fn t ->
        [t.id, t.date, t.category.name, t.description, t.amount]
      end)

    csv_data =
      [@header | transaction_data]
      |> CSV.dump_to_iodata()

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=\"transaction_export.csv\"")
    |> put_root_layout(html: false)
    |> send_resp(200, csv_data)
  end
end
