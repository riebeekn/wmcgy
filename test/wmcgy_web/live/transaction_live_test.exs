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
          # set a description so we can test sorting by description
          transaction_fixture(user, category, %{date: two_days_ago, description: "za description"})
        end

      transactions_for_second_page =
        for _i <- 1..30 do
          transaction_fixture(user, category, %{
            date: three_days_ago,
            description: "a description"
          })
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

    test "sort results appropriately when passed a sort field and direction", %{
      conn: conn,
      transactions_for_first_page: transactions_for_first_page,
      transactions_for_second_page: transactions_for_second_page
    } do
      # switch the default sort direction and field, 2nd page transactions should show on the first
      # page when sorting by description ascending
      {:ok, view, _html} = live(conn, ~p"/transactions?sort_field=description&sort_dir=asc")

      Enum.each(
        transactions_for_first_page,
        &refute(has_element?(view, "#transactions-row-#{&1.id}"))
      )

      Enum.each(
        transactions_for_second_page,
        &assert(has_element?(view, "#transactions-row-#{&1.id}"))
      )
    end

    test "sorts results when a header column is clicked", %{
      conn: conn,
      transactions_for_first_page: transactions_for_first_page,
      transactions_for_second_page: transactions_for_second_page
    } do
      {:ok, view, _html} = live(conn, ~p"/transactions?sort_field=description&sort_dir=desc")

      view
      |> element("a", "Description")
      |> render_click()

      Enum.each(
        transactions_for_first_page,
        &refute(has_element?(view, "#transactions-row-#{&1.id}"))
      )

      Enum.each(
        transactions_for_second_page,
        &assert(has_element?(view, "#transactions-row-#{&1.id}"))
      )

      view
      |> element("a", "Description")
      |> render_click()

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
