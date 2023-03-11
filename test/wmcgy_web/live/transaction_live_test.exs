defmodule WmcgyWeb.TransactionLiveTest do
  use WmcgyWebTest.ConnCase

  import Phoenix.LiveViewTest
  import WmcgyTest.CategoriesFixtures
  import WmcgyTest.TransactionsFixtures

  describe "when not logged in" do
    test "redirects to log in when attempting to access page", %{conn: conn} do
      assert {:error, {:redirect, redirect_map}} = live(conn, ~p"/")
      assert redirect_map.to == ~p"/users/log_in"
    end
  end

  describe "Index" do
    setup :register_and_log_in_user

    setup(%{user: user}) do
      category = category_fixture(user)
      two_days_ago = Date.utc_today() |> Date.add(-2)
      three_days_ago = Date.utc_today() |> Date.add(-3)

      transactions_for_first_page =
        for _i <- 1..30 do
          transaction_fixture(user, category, %{date: two_days_ago})
        end

      transactions_for_second_page =
        for _i <- 1..30 do
          transaction_fixture(user, category, %{date: three_days_ago})
        end

      [
        transactions_for_first_page: transactions_for_first_page,
        transactions_for_second_page: transactions_for_second_page
      ]
    end

    test "shows the first page of transactions by default", %{
      conn: conn,
      transactions_for_first_page: transactions_for_first_page,
      transactions_for_second_page: transactions_for_second_page
    } do
      {:ok, view, _html} = live(conn, ~p"/")

      Enum.each(
        transactions_for_first_page,
        &assert(has_element?(view, "#transactions-row-#{&1.id}"))
      )

      Enum.each(
        transactions_for_second_page,
        &refute(has_element?(view, "#transactions-row-#{&1.id}"))
      )
    end
  end
end
