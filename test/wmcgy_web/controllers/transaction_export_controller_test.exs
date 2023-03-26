defmodule WmcgyWeb.TransactionExportControllerTest do
  use WmcgyWebTest.ConnCase, async: true

  import WmcgyTest.CategoriesFixtures
  import WmcgyTest.TransactionsFixtures

  alias NimbleCSV.RFC4180, as: CSV

  setup :register_and_log_in_user

  describe "create" do
    setup %{user: user} do
      category_1 = category_fixture(user, "first category")
      category_2 = category_fixture(user, "second category")
      category_3 = category_fixture(user, "third category")

      t1 =
        transaction_fixture(user, category_2, %{
          date: ~D[2000-02-15],
          amount: decimal(-14.23),
          description: "t1"
        })

      t2 =
        transaction_fixture(user, category_1, %{
          date: ~D[2000-02-14],
          amount: decimal(12.50),
          description: "t2"
        })

      t3 =
        transaction_fixture(user, category_3, %{
          date: ~D[2000-02-16],
          amount: decimal(-35.67),
          description: "t3"
        })

      t4 =
        transaction_fixture(user, category_2, %{
          date: ~D[2000-02-16],
          amount: decimal(44.34),
          description: "t4"
        })

      %{t1: t1, t2: t2, t3: t3, t4: t4}
    end

    test "creates the csv", %{conn: conn, t1: t1, t2: t2, t3: t3, t4: t4} do
      conn = post(conn, ~p"/transactions/export")

      assert [
               ["#{t2.id}", "2000-02-14", "first category", "t2", "12.5"],
               ["#{t1.id}", "2000-02-15", "second category", "t1", "-14.23"],
               ["#{t3.id}", "2000-02-16", "third category", "t3", "-35.67"],
               ["#{t4.id}", "2000-02-16", "second category", "t4", "44.34"]
             ] == conn.resp_body |> CSV.parse_string()
    end
  end
end
