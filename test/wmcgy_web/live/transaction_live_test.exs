defmodule WmcgyWeb.TransactionLiveTest do
  use WmcgyWebTest.ConnCase, async: true

  import Phoenix.LiveViewTest
  import WmcgyTest.AccountsFixtures
  import WmcgyTest.CategoriesFixtures
  import WmcgyTest.TransactionsFixtures

  alias Wmcgy.Repo
  alias WmcgySchema.Category
  alias WmcgySchema.Transaction

  describe "when not logged in" do
    test "redirects to log in when attempting to access page", %{conn: conn} do
      assert {:error, {:redirect, redirect_map}} = live(conn, ~p"/transactions")
      assert redirect_map.to == ~p"/users/log_in"
    end

    test "redirects to log in when attempting to access create page", %{conn: conn} do
      assert {:error, {:redirect, redirect_map}} = live(conn, ~p"/transactions/new")

      assert redirect_map.to == ~p"/users/log_in"
    end

    test "redirects to log in when attempting to access edit page", %{conn: conn} do
      user = user_fixture()
      category = category_fixture(user)
      transaction = transaction_fixture(user, category)

      assert {:error, {:redirect, redirect_map}} =
               live(conn, ~p"/transactions/#{transaction.id}/edit")

      assert redirect_map.to == ~p"/users/log_in"
    end

    test "redirects to log in when attempting to access import page", %{conn: conn} do
      assert {:error, {:redirect, redirect_map}} = live(conn, ~p"/transactions/import")

      assert redirect_map.to == "/users/log_in"
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
      {:ok, view, _html} = live(conn, ~p"/transactions")

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
      {:ok, view, _html} = live(conn, ~p"/transactions")

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
      {:ok, view, _html} = live(conn, ~p"/transactions")

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

    test "when there are no categories, displays the intro text", %{conn: conn} do
      Repo.delete_all(Transaction)
      Repo.delete_all(Category)

      {:ok, _view, html} = live(conn, ~p"/transactions")

      assert html =~ "Welcome to WMCGY!"
      assert html =~ "Start things off by creating some categories."
      assert html =~ "Create some categories"
    end
  end

  describe "Create" do
    setup :register_and_log_in_user

    setup %{user: user} do
      category = category_fixture(user)

      [
        category: category
      ]
    end

    test "saves a new transaction with valid attribute", %{conn: conn, category: category} do
      {:ok, view, _html} = live(conn, ~p"/transactions/new")
      assert has_element?(view, "h1", "Add Transaction")

      {:ok, _view, html} =
        view
        |> form("#transaction-form", %{
          "transaction" => %{
            "description" => "a description for our transaction!",
            "date" => "Jun 04, 2021",
            "amount" => "1.23",
            "type" => "expense",
            "category_id" => category.id
          }
        })
        |> render_submit()
        |> follow_redirect(conn, ~p"/transactions")

      assert html =~ "Transaction created"
      assert html =~ "a description for our transaction!"
    end

    test "displays errors with invalid attributes", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/transactions/new")

      view
      |> form("#transaction-form", %{"transaction" => %{}})

      assert view
             |> form("#transaction-form", %{"transaction" => %{}})
             |> render_submit() =~ "can&#39;t be blank"
    end
  end

  describe "Edit" do
    setup :register_and_log_in_user

    setup(%{user: user}) do
      category = category_fixture(user)
      transaction = transaction_fixture(user, category)

      [
        category: category,
        transaction: transaction
      ]
    end

    test "edits the transaction when passed valid attrs", %{
      conn: conn,
      category: category,
      transaction: transaction
    } do
      {:ok, view, _html} = live(conn, ~p"/transactions/#{transaction.id}/edit")
      assert has_element?(view, "h1", "Edit Transaction")

      {:ok, _view, html} =
        view
        |> form("#transaction-form", %{
          "transaction" => %{
            "description" => "an updated description for our transaction!",
            "date" => "Jan 23, 2001",
            "amount" => "1.23",
            "type" => "expense",
            "category_id" => category.id
          }
        })
        |> render_submit()
        |> follow_redirect(conn, ~p"/transactions")

      assert html =~ "Transaction updated"
      assert html =~ "an updated description for our transaction!"
    end

    test "displays errors with invalid attributes", %{conn: conn, transaction: transaction} do
      {:ok, view, _html} = live(conn, ~p"/transactions/#{transaction.id}/edit")

      view
      |> form("#transaction-form", %{"transaction" => %{"amount" => nil}})
      |> render_submit()

      assert view
             |> form("#transaction-form", %{"transaction" => %{}})
             |> render_submit() =~ "can&#39;t be blank"
    end
  end

  describe "Delete" do
    setup :register_and_log_in_user

    setup(%{user: user}) do
      category = category_fixture(user)
      transaction = transaction_fixture(user, category)

      [
        transaction: transaction
      ]
    end

    test "deletes transaction in listing", %{conn: conn, transaction: transaction} do
      {:ok, index_live, _html} = live(conn, ~p"/transactions")

      assert index_live
             |> element("#transactions-row-#{transaction.id} a", "Delete")
             |> render_click()

      refute has_element?(index_live, "#transactions-row-#{transaction.id}")
    end
  end

  describe "Import" do
    setup :register_and_log_in_user

    test "file name preview is displayed after selecting a data file", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/transactions/import")

      view |> upload("transactions_import_data.csv")

      assert has_element?(view, "[data-role='file-path-preview']", "transactions_import_data.csv")
    end

    test "error message is displayed when the file is too big", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/transactions/import")

      view |> upload("too_big.csv")

      assert has_element?(
               view,
               "[data-role='validation-error']",
               "File too large, max file size is 8MB"
             )
    end

    test "error message is displayed when the header is invalid", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/transactions/import")

      view
      |> upload("bad_header.csv")
      |> form("#transaction-import")
      |> render_submit()

      assert has_element?(
               view,
               "[data-role='spinner-text']",
               "Sorry that is an invalid file, nothing imported!"
             )
    end

    test "import stats are displayed upon success", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/transactions/import")

      view
      |> upload("transactions_import_data.csv")
      |> form("#transaction-import")
      |> render_submit()

      assert has_element?(
               view,
               "[data-role='spinner-text']",
               "Import complete"
             )

      assert has_element?(view, "[data-role='new_transactions']", "New Transactions")
      assert has_element?(view, "[data-role='new_transactions']", "5")
      assert has_element?(view, "[data-role='new_transactions']", "35.71%")

      assert has_element?(view, "[data-role='updated_transactions']", "Updated Transactions")
      assert has_element?(view, "[data-role='updated_transactions']", "3")
      assert has_element?(view, "[data-role='updated_transactions']", "21.43%")

      assert has_element?(view, "[data-role='duplicate_transactions']", "Duplicate Transactions")
      assert has_element?(view, "[data-role='duplicate_transactions']", "2")
      assert has_element?(view, "[data-role='duplicate_transactions']", "14.29%")

      assert has_element?(view, "[data-role='invalid_rows']", "Invalid Rows")
      assert has_element?(view, "[data-role='invalid_rows']", "4")
      assert has_element?(view, "[data-role='invalid_rows']", "28.57%")

      assert has_element?(
               view,
               "#import-errors-message",
               "One or more rows were invalid, these rows will not be imported, see below for details."
             )

      assert has_element?(view, "#import_errors-row-0-col-0", "3")

      assert has_element?(
               view,
               "#import_errors-row-0-col-1",
               "Amount: can't be blank, Date: can't be blank, Id: can't be blank"
             )

      assert has_element?(view, "#import_errors-row-0-col-2", "Not imported")

      assert has_element?(view, "#import_errors-row-1-col-0", "9")
      assert has_element?(view, "#import_errors-row-1-col-1", "Category name: can't be blank")
      assert has_element?(view, "#import_errors-row-1-col-2", "Not imported")

      assert has_element?(view, "#import_errors-row-2-col-0", "12")

      assert has_element?(
               view,
               "#import_errors-row-2-col-1",
               "Category name: should be at least 3 character(s)"
             )

      assert has_element?(view, "#import_errors-row-2-col-2", "Not imported")

      assert has_element?(view, "#import_errors-row-3-col-0", "14")
      assert has_element?(view, "#import_errors-row-3-col-1", "Date: is invalid")
      assert has_element?(view, "#import_errors-row-3-col-2", "Not imported")
    end

    test "import can process multiple chunks", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/transactions/import")

      view
      |> upload("transactions_import_data_multiple_chunks.csv")
      |> form("#transaction-import")
      |> render_submit()

      # sleep to allow the chunks to process
      Process.sleep(500)

      assert has_element?(
               view,
               "[data-role='spinner-text']",
               "Import complete"
             )

      assert has_element?(view, "[data-role='new_transactions']", "New Transactions")
      assert has_element?(view, "[data-role='new_transactions']", "5")
      assert has_element?(view, "[data-role='new_transactions']", "4.46%")

      assert has_element?(view, "[data-role='updated_transactions']", "Updated Transactions")
      assert has_element?(view, "[data-role='updated_transactions']", "38")
      assert has_element?(view, "[data-role='updated_transactions']", "33.93%")

      assert has_element?(view, "[data-role='duplicate_transactions']", "Duplicate Transactions")
      assert has_element?(view, "[data-role='duplicate_transactions']", "37")
      assert has_element?(view, "[data-role='duplicate_transactions']", "33.04%")

      assert has_element?(view, "[data-role='invalid_rows']", "Invalid Rows")
      assert has_element?(view, "[data-role='invalid_rows']", "32")
      assert has_element?(view, "[data-role='invalid_rows']", "28.57%")
    end

    defp upload(view, filename) do
      view
      |> file_input("#transaction-import", :transaction_data, [
        %{
          name: filename,
          content: File.read!("test/support/data/#{filename}"),
          type: "text/csv"
        }
      ])
      |> render_upload(filename)

      view
    end
  end
end
