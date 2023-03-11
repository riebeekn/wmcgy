defmodule WmcgyWeb.TransactionLiveTest do
  use WmcgyWebTest.ConnCase, async: true

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

    test "limits results appropriately when passed a page number", %{
      conn: conn,
      transactions_for_first_page: transactions_for_first_page,
      transactions_for_second_page: transactions_for_second_page
    } do
      {:ok, view, _html} = live(conn, ~p"/transactions?page=2")

      Enum.each(
        transactions_for_first_page,
        &refute(has_element?(view, "#transactions-row-#{&1.id}"))
      )

      Enum.each(
        transactions_for_second_page,
        &assert(has_element?(view, "#transactions-row-#{&1.id}"))
      )
    end

    test "limits results appropriately when passed a page size", %{
      conn: conn,
      transactions_for_first_page: transactions_for_first_page,
      transactions_for_second_page: transactions_for_second_page
    } do
      {:ok, view, _html} = live(conn, ~p"/transactions?page_size=3")

      {transactions_on_other_pages, transaction_on_first_page} =
        Enum.split(transactions_for_first_page, 27)

      Enum.each(
        transaction_on_first_page,
        &assert(has_element?(view, "#transactions-row-#{&1.id}"))
      )

      Enum.each(
        transactions_for_second_page ++ transactions_on_other_pages,
        &refute(has_element?(view, "#transactions-row-#{&1.id}"))
      )
    end

    test "shows default number of entries when passed invalid page size", %{
      conn: conn,
      transactions_for_first_page: transactions_for_first_page,
      transactions_for_second_page: transactions_for_second_page
    } do
      {:ok, view, _html} = live(conn, ~p"/transactions?page_size=notapagesize!")

      Enum.each(
        transactions_for_first_page,
        &assert(has_element?(view, "#transactions-row-#{&1.id}"))
      )

      Enum.each(
        transactions_for_second_page,
        &refute(has_element?(view, "#transactions-row-#{&1.id}"))
      )
    end

    test "shows page one when page is less than one", %{
      conn: conn,
      transactions_for_first_page: transactions_for_first_page,
      transactions_for_second_page: transactions_for_second_page
    } do
      {:ok, view, _html} = live(conn, ~p"/transactions?page=0")

      Enum.each(
        transactions_for_first_page,
        &assert(has_element?(view, "#transactions-row-#{&1.id}"))
      )

      Enum.each(
        transactions_for_second_page,
        &refute(has_element?(view, "#transactions-row-#{&1.id}"))
      )
    end

    test "shows page one when an invalid page is passed in", %{
      conn: conn,
      transactions_for_first_page: transactions_for_first_page,
      transactions_for_second_page: transactions_for_second_page
    } do
      {:ok, view, _html} = live(conn, ~p"/transactions?page=notapage!")

      Enum.each(
        transactions_for_first_page,
        &assert(has_element?(view, "#transactions-row-#{&1.id}"))
      )

      Enum.each(
        transactions_for_second_page,
        &refute(has_element?(view, "#transactions-row-#{&1.id}"))
      )
    end

    test "shows last page when passed in page exceeds the max number of pages", %{
      conn: conn,
      transactions_for_first_page: transactions_for_first_page,
      transactions_for_second_page: transactions_for_second_page
    } do
      {:ok, view, _html} = live(conn, ~p"/transactions?page=3")

      Enum.each(
        transactions_for_first_page,
        &refute(has_element?(view, "#transactions-row-#{&1.id}"))
      )

      Enum.each(
        transactions_for_second_page,
        &assert(has_element?(view, "#transactions-row-#{&1.id}"))
      )
    end

    test "displays paging status", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/transactions?page=0")
      assert html |> strip_html() =~ "Showing 1 to 30 of 60 results"

      {:ok, _view, html} = live(conn, ~p"/transactions?page=1")
      assert html |> strip_html() =~ "Showing 1 to 30 of 60 results"

      {:ok, _view, html} = live(conn, ~p"/transactions?page=2")
      assert html |> strip_html() =~ "Showing 31 to 60 of 60 results"

      {:ok, _view, html} = live(conn, ~p"/transactions?page=3")
      assert html |> strip_html() =~ "Showing 31 to 60 of 60 results"

      # check the scenario where current page > total pages and the number
      # of entries does not result in full pages
      {:ok, _view, html} = live(conn, ~p"/transactions?page=9&page_size=8")

      assert html |> strip_html() =~ "Showing 57 to 60 of 60 results"
    end

    test "moves to the next page when next page is clicked", %{
      conn: conn,
      transactions_for_first_page: transactions_for_first_page,
      transactions_for_second_page: transactions_for_second_page
    } do
      {:ok, view, _html} = live(conn, ~p"/")

      view
      |> element("#transactions-top-pager button", "Next")
      |> render_click()

      Enum.each(
        transactions_for_first_page,
        &refute(has_element?(view, "#transactions-row-#{&1.id}"))
      )

      Enum.each(
        transactions_for_second_page,
        &assert(has_element?(view, "#transactions-row-#{&1.id}"))
      )
    end

    test "stays on current page when next page is clicked and already on the last page", %{
      conn: conn,
      transactions_for_first_page: transactions_for_first_page,
      transactions_for_second_page: transactions_for_second_page
    } do
      {:ok, view, _html} = live(conn, ~p"/transactions?page=2")

      view
      |> element("#transactions-top-pager button", "Next")
      |> render_click()

      Enum.each(
        transactions_for_first_page,
        &refute(has_element?(view, "#transactions-row-#{&1.id}"))
      )

      Enum.each(
        transactions_for_second_page,
        &assert(has_element?(view, "#transactions-row-#{&1.id}"))
      )
    end

    test "moves to the previous page when previous page is clicked", %{
      conn: conn,
      transactions_for_first_page: transactions_for_first_page,
      transactions_for_second_page: transactions_for_second_page
    } do
      {:ok, view, _html} = live(conn, ~p"/transactions?page=2")

      view
      |> element("#transactions-top-pager button", "Previous")
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

    test "stays on the first page when previous page is clicked and currently on first page", %{
      conn: conn,
      transactions_for_first_page: transactions_for_first_page,
      transactions_for_second_page: transactions_for_second_page
    } do
      {:ok, view, _html} = live(conn, ~p"/")

      view
      |> element("#transactions-top-pager button", "Previous")
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
