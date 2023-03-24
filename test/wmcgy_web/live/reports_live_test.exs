defmodule WmcgyWeb.ReportsLiveTest do
  use WmcgyWebTest.ConnCase

  import Phoenix.LiveViewTest
  import WmcgyTest.CategoriesFixtures
  import WmcgyTest.TransactionsFixtures

  alias Wmcgy.Repo
  alias WmcgySchema.Transaction
  alias WmcgyWeb.InjectWallDate

  describe "when not logged in" do
    test "redirects to log in when attempting to access page", %{conn: conn} do
      assert {:error, {:redirect, redirect_map}} = live(conn, ~p"/reports")

      assert redirect_map.to == "/users/log_in"
    end
  end

  describe "Category reports" do
    setup :register_and_log_in_user

    setup %{user: user} do
      # set up a few categories
      groc = category_fixture(user, "Groceries")
      enter = category_fixture(user, "Entertainment")
      pay = category_fixture(user, "Pay")

      # create a few transactions for "today"... which is mocked as 2020-08-21
      today = InjectWallDate.mocked_wall_date()

      transaction_fixture(user, groc, %{date: today, amount: -140})
      transaction_fixture(user, enter, %{date: today, amount: -40})
      transaction_fixture(user, pay, %{date: today, amount: 4000})

      # create a few transactions for Mar 2020
      transaction_fixture(user, groc, %{date: ~D[2020-03-15], amount: -200})
      transaction_fixture(user, enter, %{date: ~D[2020-03-15], amount: -120})
      transaction_fixture(user, pay, %{date: ~D[2020-03-15], amount: 3000})

      :ok
    end

    test "on page load pushes transactions for the current month to charts", %{
      conn: conn
    } do
      {:ok, view, _html} = live(conn, ~p"/reports")

      expected_expense_percentages = [decimal(22.2), decimal(77.8)]
      expected_expense_values = [decimal(40), decimal(140)]

      assert_push_event(view, :expense_chart_update, %{
        labels: ["Entertainment", "Groceries"],
        percentages: ^expected_expense_percentages,
        values: ^expected_expense_values
      })

      expected_income_percentages = [decimal(100.0)]
      expected_income_values = [decimal(4000)]

      assert_push_event(view, :income_chart_update, %{
        labels: ["Pay"],
        percentages: ^expected_income_percentages,
        values: ^expected_income_values
      })
    end

    test "on page load detail tables contain the current month's transactions", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/reports")

      # expense details
      assert has_element?(view, "#expenses_table_data")
      assert has_element?(view, "#expenses_table_data-row-0-col-0", "Entertainment")
      assert has_element?(view, "#expenses_table_data-row-0-col-1", "$40.00")
      assert has_element?(view, "#expenses_table_data-row-1-col-0", "Groceries")
      assert has_element?(view, "#expenses_table_data-row-1-col-1", "$140.00")
      assert has_element?(view, "#expenses_table_data-footer-col-0", "Total")
      assert has_element?(view, "#expenses_table_data-footer-col-1", "$180.00")

      # income details
      assert has_element?(view, "#income_table_data")
      assert has_element?(view, "#income_table_data-row-0-col-0", "Pay")
      assert has_element?(view, "#income_table_data-row-0-col-1", "$4,000.00")
      assert has_element?(view, "#income_table_data-footer-col-0", "Total")
      assert has_element?(view, "#income_table_data-footer-col-1", "$4,000.00")
    end

    test "pushes all transactions when start date changed to Mar 15 2020", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/reports")

      view
      |> form("#start_date_form", %{
        "start_date_form" => %{
          "start_date" => "Mar 15, 2020"
        }
      })
      |> render_change()

      expected_expense_percentages = [decimal(32.0), decimal(68.0)]
      expected_expense_values = [decimal(160), decimal(340)]

      assert_push_event(view, :expense_chart_update, %{
        labels: ["Entertainment", "Groceries"],
        percentages: ^expected_expense_percentages,
        values: ^expected_expense_values
      })

      expected_income_percentages = [decimal(100.0)]
      expected_income_values = [decimal(7000)]

      assert_push_event(view, :income_chart_update, %{
        labels: ["Pay"],
        percentages: ^expected_income_percentages,
        values: ^expected_income_values
      })
    end

    test "details tables contain all data when start date changed to Mar 15 2020", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/reports")

      view
      |> form("#start_date_form", %{
        "start_date_form" => %{
          "start_date" => "Mar 15, 2020"
        }
      })
      |> render_change()

      # expense details
      assert has_element?(view, "#expenses_table_data")
      assert has_element?(view, "#expenses_table_data-row-0-col-0", "Entertainment")
      assert has_element?(view, "#expenses_table_data-row-0-col-1", "$160.00")
      assert has_element?(view, "#expenses_table_data-row-1-col-0", "Groceries")
      assert has_element?(view, "#expenses_table_data-row-1-col-1", "$340.00")
      assert has_element?(view, "#expenses_table_data-footer-col-0", "Total")
      assert has_element?(view, "#expenses_table_data-footer-col-1", "$500.00")

      # income details
      assert has_element?(view, "#income_table_data")
      assert has_element?(view, "#income_table_data-row-0-col-0", "Pay")
      assert has_element?(view, "#income_table_data-row-0-col-1", "$7,000.00")
      assert has_element?(view, "#income_table_data-footer-col-0", "Total")
      assert has_element?(view, "#income_table_data-footer-col-1", "$7,000.00")
    end

    test "pushes just March transactions when start and end date changed to Mar 15 2020", %{
      conn: conn
    } do
      {:ok, view, _html} = live(conn, ~p"/reports")

      view
      |> form("#start_date_form", %{
        "start_date_form" => %{
          "start_date" => "Mar 15, 2020"
        }
      })
      |> render_change()

      view
      |> form("#end_date_form", %{
        "end_date_form" => %{
          "end_date" => "Mar 15, 2020"
        }
      })
      |> render_change()

      expected_expense_percentages = [decimal(37.5), decimal(62.5)]
      expected_expense_values = [decimal(120), decimal(200)]

      assert_push_event(view, :expense_chart_update, %{
        labels: ["Entertainment", "Groceries"],
        percentages: ^expected_expense_percentages,
        values: ^expected_expense_values
      })

      expected_income_percentages = [decimal(100.0)]
      expected_income_values = [decimal(3000)]

      assert_push_event(view, :income_chart_update, %{
        labels: ["Pay"],
        percentages: ^expected_income_percentages,
        values: ^expected_income_values
      })
    end

    test "details tables show just March data when start and end date changed to Mar 15 2020", %{
      conn: conn
    } do
      {:ok, view, _html} = live(conn, ~p"/reports")

      view
      |> form("#start_date_form", %{
        "start_date_form" => %{
          "start_date" => "Mar 15, 2020"
        }
      })
      |> render_change()

      view
      |> form("#end_date_form", %{
        "end_date_form" => %{
          "end_date" => "Mar 15, 2020"
        }
      })
      |> render_change()

      # expense details
      assert has_element?(view, "#expenses_table_data")
      assert has_element?(view, "#expenses_table_data-row-0-col-0", "Entertainment")
      assert has_element?(view, "#expenses_table_data-row-0-col-1", "$120.00")
      assert has_element?(view, "#expenses_table_data-row-1-col-0", "Groceries")
      assert has_element?(view, "#expenses_table_data-row-1-col-1", "$200.00")
      assert has_element?(view, "#expenses_table_data-footer-col-0", "Total")
      assert has_element?(view, "#expenses_table_data-footer-col-1", "$320.00")

      # income details
      assert has_element?(view, "#income_table_data")
      assert has_element?(view, "#income_table_data-row-0-col-0", "Pay")
      assert has_element?(view, "#income_table_data-row-0-col-1", "$3,000.00")
      assert has_element?(view, "#income_table_data-footer-col-0", "Total")
      assert has_element?(view, "#income_table_data-footer-col-1", "$3,000.00")
    end

    test "pushes no transaction when none fall within the date filters", %{
      conn: conn
    } do
      {:ok, view, _html} = live(conn, ~p"/reports")

      view
      |> form("#start_date_form", %{
        "start_date_form" => %{
          "start_date" => "Mar 14, 2020"
        }
      })
      |> render_change()

      view
      |> form("#end_date_form", %{
        "end_date_form" => %{
          "end_date" => "Mar 14, 2020"
        }
      })
      |> render_change()

      assert_push_event(view, :expense_chart_update, %{
        labels: [],
        percentages: [],
        values: []
      })

      assert_push_event(view, :income_chart_update, %{
        labels: [],
        percentages: [],
        values: []
      })
    end

    test "details tables not available when there are no transactions", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/reports")

      view
      |> form("#start_date_form", %{
        "start_date_form" => %{
          "start_date" => "Mar 14, 2020"
        }
      })
      |> render_change()

      view
      |> form("#end_date_form", %{
        "end_date_form" => %{
          "end_date" => "Mar 14, 2020"
        }
      })
      |> render_change()

      # expense details
      refute has_element?(view, "#expenses_table_data")

      # income details
      refute has_element?(view, "#income_table_data")
    end
  end

  describe "Monthly / Yearly reports" do
    setup :register_and_log_in_user

    setup %{user: user} do
      category = category_fixture(user)

      # create a few transactions for "today"... which is mocked as 2020-08-21
      today = InjectWallDate.mocked_wall_date()

      transaction_fixture(user, category, %{date: today, amount: -140})
      transaction_fixture(user, category, %{date: today, amount: -40})
      transaction_fixture(user, category, %{date: today, amount: 4000})

      # now a few for July
      transaction_fixture(user, category, %{date: ~D[2020-07-15], amount: -350})
      transaction_fixture(user, category, %{date: ~D[2020-07-15], amount: -25})
      transaction_fixture(user, category, %{date: ~D[2020-07-15], amount: 3000})

      # some for May
      transaction_fixture(user, category, %{date: ~D[2020-05-15], amount: -225})
      transaction_fixture(user, category, %{date: ~D[2020-05-15], amount: 8000})

      # create a few transactions for 2019
      transaction_fixture(user, category, %{date: ~D[2019-10-25], amount: -10})
      transaction_fixture(user, category, %{date: ~D[2019-10-15], amount: -50})
      transaction_fixture(user, category, %{date: ~D[2019-09-15], amount: 1500})
      transaction_fixture(user, category, %{date: ~D[2019-09-15], amount: -500})

      :ok
    end

    test "on page load pushes transaction for the current year to charts", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/reports")

      expected_labels = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug"]

      expected_income = [
        decimal(0),
        decimal(0),
        decimal(0),
        decimal(0),
        # May
        decimal(8000),
        decimal(0),
        # July
        decimal(3000),
        # August
        decimal(4000)
      ]

      expected_expense = [
        decimal(0),
        decimal(0),
        decimal(0),
        decimal(0),
        # May
        decimal(225),
        decimal(0),
        # July
        decimal(375),
        # August
        decimal(180)
      ]

      expected_profit = [
        decimal(0),
        decimal(0),
        decimal(0),
        decimal(0),
        # May
        decimal(7775),
        decimal(0),
        # July
        decimal(2625),
        # August
        decimal(3820)
      ]

      expected_loss = [
        decimal(0),
        decimal(0),
        decimal(0),
        decimal(0),
        decimal(0),
        decimal(0),
        decimal(0),
        decimal(0)
      ]

      assert_push_event(view, :income_expense_chart_update, %{
        labels: ^expected_labels,
        datasets: [
          %{label: "Income", data: ^expected_income},
          %{label: "Expense", data: ^expected_expense}
        ]
      })

      assert_push_event(view, :profit_loss_chart_update, %{
        labels: ^expected_labels,
        datasets: [
          %{label: "Profit", data: ^expected_profit},
          %{label: "Loss", data: ^expected_loss}
        ]
      })
    end

    test "on page load detail tables contain the ytd data", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/reports")

      # income / expense
      assert has_element?(view, "#income_expense_table_data")
      assert has_element?(view, "#income_expense_table_data-row-0-col-0", "Jan")
      assert has_element?(view, "#income_expense_table_data-row-0-col-1", "$0.00")
      assert has_element?(view, "#income_expense_table_data-row-0-col-2", "$0.00")
      assert has_element?(view, "#income_expense_table_data-row-1-col-0", "Feb")
      assert has_element?(view, "#income_expense_table_data-row-1-col-1", "$0.00")
      assert has_element?(view, "#income_expense_table_data-row-1-col-2", "$0.00")
      assert has_element?(view, "#income_expense_table_data-row-2-col-0", "Mar")
      assert has_element?(view, "#income_expense_table_data-row-2-col-1", "$0.00")
      assert has_element?(view, "#income_expense_table_data-row-2-col-2", "$0.00")
      assert has_element?(view, "#income_expense_table_data-row-3-col-0", "Apr")
      assert has_element?(view, "#income_expense_table_data-row-3-col-1", "$0.00")
      assert has_element?(view, "#income_expense_table_data-row-3-col-2", "$0.00")
      assert has_element?(view, "#income_expense_table_data-row-4-col-0", "May")
      assert has_element?(view, "#income_expense_table_data-row-4-col-1", "$8,000.00")
      assert has_element?(view, "#income_expense_table_data-row-4-col-2", "$225.00")
      assert has_element?(view, "#income_expense_table_data-row-5-col-0", "Jun")
      assert has_element?(view, "#income_expense_table_data-row-5-col-1", "$0.00")
      assert has_element?(view, "#income_expense_table_data-row-5-col-2", "$0.00")
      assert has_element?(view, "#income_expense_table_data-row-6-col-0", "Jul")
      assert has_element?(view, "#income_expense_table_data-row-6-col-1", "$3,000.00")
      assert has_element?(view, "#income_expense_table_data-row-6-col-2", "$375.00")
      assert has_element?(view, "#income_expense_table_data-row-7-col-0", "Aug")
      assert has_element?(view, "#income_expense_table_data-row-7-col-1", "$4,000.00")
      assert has_element?(view, "#income_expense_table_data-row-7-col-2", "$180.00")
      assert has_element?(view, "#income_expense_table_data-footer-col-0", "Total")
      assert has_element?(view, "#income_expense_table_data-footer-col-1", "$15,000.00")
      assert has_element?(view, "#income_expense_table_data-footer-col-2", "$780.00")

      # profit / loss
      assert has_element?(view, "#profit_loss_table_data")
      assert has_element?(view, "#profit_loss_table_data-row-0-col-0", "Jan")
      assert has_element?(view, "#profit_loss_table_data-row-0-col-1", "$0.00")
      assert has_element?(view, "#profit_loss_table_data-row-1-col-0", "Feb")
      assert has_element?(view, "#profit_loss_table_data-row-1-col-1", "$0.00")
      assert has_element?(view, "#profit_loss_table_data-row-2-col-0", "Mar")
      assert has_element?(view, "#profit_loss_table_data-row-2-col-1", "$0.00")
      assert has_element?(view, "#profit_loss_table_data-row-3-col-0", "Apr")
      assert has_element?(view, "#profit_loss_table_data-row-3-col-1", "$0.00")
      assert has_element?(view, "#profit_loss_table_data-row-4-col-0", "May")
      assert has_element?(view, "#profit_loss_table_data-row-4-col-1", "$7,775.00")
      assert has_element?(view, "#profit_loss_table_data-row-5-col-0", "Jun")
      assert has_element?(view, "#profit_loss_table_data-row-5-col-1", "$0.00")
      assert has_element?(view, "#profit_loss_table_data-row-6-col-0", "Jul")
      assert has_element?(view, "#profit_loss_table_data-row-6-col-1", "$2,625.00")
      assert has_element?(view, "#profit_loss_table_data-row-7-col-0", "Aug")
      assert has_element?(view, "#profit_loss_table_data-row-7-col-1", "$3,820.00")
      assert has_element?(view, "#profit_loss_table_data-footer-col-0", "Total")
      assert has_element?(view, "#profit_loss_table_data-footer-col-1", "$14,220.00")
    end

    test "pushes transactions for the last 12 months when filtering to last 12", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/reports")

      view
      |> form("#date_options", %{"date_options_form" => %{"date_option" => "last_12"}})
      |> render_change()

      expected_labels = [
        "Sep",
        "Oct",
        "Nov",
        "Dec",
        "Jan",
        "Feb",
        "Mar",
        "Apr",
        "May",
        "Jun",
        "Jul",
        "Aug"
      ]

      expected_income = [
        # Sept 2019
        decimal(1500),
        decimal(0),
        decimal(0),
        decimal(0),
        decimal(0),
        decimal(0),
        decimal(0),
        decimal(0),
        # May 2020
        decimal(8000),
        decimal(0),
        # July 2020
        decimal(3000),
        # August 2020
        decimal(4000)
      ]

      expected_expense = [
        # Sept 2019
        decimal(500),
        # Oct 2019
        decimal(60),
        decimal(0),
        decimal(0),
        decimal(0),
        decimal(0),
        decimal(0),
        decimal(0),
        # May 2020
        decimal(225),
        decimal(0),
        # July 2020
        decimal(375),
        # August 2020
        decimal(180)
      ]

      expected_profit = [
        # Sept 2019
        decimal(1000),
        decimal(0),
        decimal(0),
        decimal(0),
        decimal(0),
        decimal(0),
        decimal(0),
        decimal(0),
        # May 2020
        decimal(7775),
        decimal(0),
        # July 2020
        decimal(2625),
        # August 2020
        decimal(3820)
      ]

      expected_loss = [
        decimal(0),
        # Oct 2019
        decimal(-60),
        decimal(0),
        decimal(0),
        decimal(0),
        decimal(0),
        decimal(0),
        decimal(0),
        decimal(0),
        decimal(0),
        decimal(0),
        decimal(0)
      ]

      assert_push_event(view, :income_expense_chart_update, %{
        labels: ^expected_labels,
        datasets: [
          %{label: "Income", data: ^expected_income},
          %{label: "Expense", data: ^expected_expense}
        ]
      })

      assert_push_event(view, :profit_loss_chart_update, %{
        labels: ^expected_labels,
        datasets: [
          %{label: "Profit", data: ^expected_profit},
          %{label: "Loss", data: ^expected_loss}
        ]
      })
    end

    test "loads details for the last 12 months when filtering by last 12", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/reports")

      view
      |> form("#date_options", %{"date_options_form" => %{"date_option" => "last_12"}})
      |> render_change()

      # income / expense
      assert has_element?(view, "#income_expense_table_data")
      assert has_element?(view, "#income_expense_table_data-row-0-col-0", "Sep")
      assert has_element?(view, "#income_expense_table_data-row-0-col-1", "$1,500.00")
      assert has_element?(view, "#income_expense_table_data-row-0-col-2", "$500.00")
      assert has_element?(view, "#income_expense_table_data-row-1-col-0", "Oct")
      assert has_element?(view, "#income_expense_table_data-row-1-col-1", "$0.00")
      assert has_element?(view, "#income_expense_table_data-row-1-col-2", "$60.00")
      assert has_element?(view, "#income_expense_table_data-row-2-col-0", "Nov")
      assert has_element?(view, "#income_expense_table_data-row-2-col-1", "$0.00")
      assert has_element?(view, "#income_expense_table_data-row-2-col-2", "$0.00")
      assert has_element?(view, "#income_expense_table_data-row-3-col-0", "Dec")
      assert has_element?(view, "#income_expense_table_data-row-3-col-1", "$0.00")
      assert has_element?(view, "#income_expense_table_data-row-3-col-2", "$0.00")
      assert has_element?(view, "#income_expense_table_data-row-4-col-0", "Jan")
      assert has_element?(view, "#income_expense_table_data-row-4-col-1", "$0.00")
      assert has_element?(view, "#income_expense_table_data-row-4-col-2", "$0.00")
      assert has_element?(view, "#income_expense_table_data-row-5-col-0", "Feb")
      assert has_element?(view, "#income_expense_table_data-row-5-col-1", "$0.00")
      assert has_element?(view, "#income_expense_table_data-row-5-col-2", "$0.00")
      assert has_element?(view, "#income_expense_table_data-row-6-col-0", "Mar")
      assert has_element?(view, "#income_expense_table_data-row-6-col-1", "$0.00")
      assert has_element?(view, "#income_expense_table_data-row-6-col-2", "$0.00")
      assert has_element?(view, "#income_expense_table_data-row-7-col-0", "Apr")
      assert has_element?(view, "#income_expense_table_data-row-7-col-1", "$0.00")
      assert has_element?(view, "#income_expense_table_data-row-7-col-2", "$0.00")
      assert has_element?(view, "#income_expense_table_data-row-8-col-0", "May")
      assert has_element?(view, "#income_expense_table_data-row-8-col-1", "$8,000.00")
      assert has_element?(view, "#income_expense_table_data-row-8-col-2", "$225.00")
      assert has_element?(view, "#income_expense_table_data-row-9-col-0", "Jun")
      assert has_element?(view, "#income_expense_table_data-row-9-col-1", "$0.00")
      assert has_element?(view, "#income_expense_table_data-row-9-col-2", "$0.00")
      assert has_element?(view, "#income_expense_table_data-row-10-col-0", "Jul")
      assert has_element?(view, "#income_expense_table_data-row-10-col-1", "$3,000.00")
      assert has_element?(view, "#income_expense_table_data-row-10-col-2", "$375.00")
      assert has_element?(view, "#income_expense_table_data-row-11-col-0", "Aug")
      assert has_element?(view, "#income_expense_table_data-row-11-col-1", "$4,000.00")
      assert has_element?(view, "#income_expense_table_data-row-11-col-2", "$180.00")
      assert has_element?(view, "#income_expense_table_data-footer-col-0", "Total")
      assert has_element?(view, "#income_expense_table_data-footer-col-1", "$16,500.00")
      assert has_element?(view, "#income_expense_table_data-footer-col-2", "$1,340.00")

      # profit / loss
      assert has_element?(view, "#profit_loss_table_data")
      assert has_element?(view, "#profit_loss_table_data-row-0-col-0", "Sep")
      assert has_element?(view, "#profit_loss_table_data-row-0-col-1", "$1,000.00")
      assert has_element?(view, "#profit_loss_table_data-row-1-col-0", "Oct")
      assert has_element?(view, "#profit_loss_table_data-row-1-col-1", "-$60.00")
      assert has_element?(view, "#profit_loss_table_data-row-2-col-0", "Nov")
      assert has_element?(view, "#profit_loss_table_data-row-2-col-1", "$0.00")
      assert has_element?(view, "#profit_loss_table_data-row-3-col-0", "Dec")
      assert has_element?(view, "#profit_loss_table_data-row-3-col-1", "$0.00")
      assert has_element?(view, "#profit_loss_table_data-row-4-col-0", "Jan")
      assert has_element?(view, "#profit_loss_table_data-row-4-col-1", "$0.00")
      assert has_element?(view, "#profit_loss_table_data-row-5-col-0", "Feb")
      assert has_element?(view, "#profit_loss_table_data-row-5-col-1", "$0.00")
      assert has_element?(view, "#profit_loss_table_data-row-6-col-0", "Mar")
      assert has_element?(view, "#profit_loss_table_data-row-6-col-1", "$0.00")
      assert has_element?(view, "#profit_loss_table_data-row-7-col-0", "Apr")
      assert has_element?(view, "#profit_loss_table_data-row-7-col-1", "$0.00")
      assert has_element?(view, "#profit_loss_table_data-row-8-col-0", "May")
      assert has_element?(view, "#profit_loss_table_data-row-8-col-1", "$7,775.00")
      assert has_element?(view, "#profit_loss_table_data-row-9-col-0", "Jun")
      assert has_element?(view, "#profit_loss_table_data-row-9-col-1", "$0.00")
      assert has_element?(view, "#profit_loss_table_data-row-10-col-0", "Jul")
      assert has_element?(view, "#profit_loss_table_data-row-10-col-1", "$2,625.00")
      assert has_element?(view, "#profit_loss_table_data-row-11-col-0", "Aug")
      assert has_element?(view, "#profit_loss_table_data-row-11-col-1", "$3,820.00")
      assert has_element?(view, "#profit_loss_table_data-footer-col-0", "Total")
      assert has_element?(view, "#profit_loss_table_data-footer-col-1", "$15,160.00")
    end

    test "pushes transactions for 2019 when filtering to 2019", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/reports")

      view
      |> form("#date_options", %{"date_options_form" => %{"date_option" => "2019"}})
      |> render_change()

      expected_labels = [
        "Jan",
        "Feb",
        "Mar",
        "Apr",
        "May",
        "Jun",
        "Jul",
        "Aug",
        "Sep",
        "Oct",
        "Nov",
        "Dec"
      ]

      expected_income = [
        decimal(0),
        decimal(0),
        decimal(0),
        decimal(0),
        decimal(0),
        decimal(0),
        decimal(0),
        decimal(0),
        # Sept
        decimal(1500),
        decimal(0),
        decimal(0),
        decimal(0)
      ]

      expected_expense = [
        decimal(0),
        decimal(0),
        decimal(0),
        decimal(0),
        decimal(0),
        decimal(0),
        decimal(0),
        decimal(0),
        # Sept
        decimal(500),
        # Oct
        decimal(60),
        decimal(0),
        decimal(0)
      ]

      expected_profit = [
        decimal(0),
        decimal(0),
        decimal(0),
        decimal(0),
        decimal(0),
        decimal(0),
        decimal(0),
        decimal(0),
        # Sept
        decimal(1000),
        decimal(0),
        decimal(0),
        decimal(0)
      ]

      expected_loss = [
        decimal(0),
        decimal(0),
        decimal(0),
        decimal(0),
        decimal(0),
        decimal(0),
        decimal(0),
        decimal(0),
        decimal(0),
        # Oct
        decimal(-60),
        decimal(0),
        decimal(0)
      ]

      assert_push_event(view, :income_expense_chart_update, %{
        labels: ^expected_labels,
        datasets: [
          %{label: "Income", data: ^expected_income},
          %{label: "Expense", data: ^expected_expense}
        ]
      })

      assert_push_event(view, :profit_loss_chart_update, %{
        labels: ^expected_labels,
        datasets: [
          %{label: "Profit", data: ^expected_profit},
          %{label: "Loss", data: ^expected_loss}
        ]
      })
    end

    test "load details for 2019 when filtering by 2019", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/reports")

      view
      |> form("#date_options", %{"date_options_form" => %{"date_option" => "2019"}})
      |> render_change()

      # income / expense
      assert has_element?(view, "#income_expense_table_data")
      assert has_element?(view, "#income_expense_table_data-row-0-col-0", "Jan")
      assert has_element?(view, "#income_expense_table_data-row-0-col-1", "$0.00")
      assert has_element?(view, "#income_expense_table_data-row-0-col-2", "$0.00")
      assert has_element?(view, "#income_expense_table_data-row-1-col-0", "Feb")
      assert has_element?(view, "#income_expense_table_data-row-1-col-1", "$0.00")
      assert has_element?(view, "#income_expense_table_data-row-1-col-2", "$0.00")
      assert has_element?(view, "#income_expense_table_data-row-2-col-0", "Mar")
      assert has_element?(view, "#income_expense_table_data-row-2-col-1", "$0.00")
      assert has_element?(view, "#income_expense_table_data-row-2-col-2", "$0.00")
      assert has_element?(view, "#income_expense_table_data-row-3-col-0", "Apr")
      assert has_element?(view, "#income_expense_table_data-row-3-col-1", "$0.00")
      assert has_element?(view, "#income_expense_table_data-row-3-col-2", "$0.00")
      assert has_element?(view, "#income_expense_table_data-row-4-col-0", "May")
      assert has_element?(view, "#income_expense_table_data-row-4-col-1", "$0.00")
      assert has_element?(view, "#income_expense_table_data-row-4-col-2", "$0.00")
      assert has_element?(view, "#income_expense_table_data-row-5-col-0", "Jun")
      assert has_element?(view, "#income_expense_table_data-row-5-col-1", "$0.00")
      assert has_element?(view, "#income_expense_table_data-row-5-col-2", "$0.00")
      assert has_element?(view, "#income_expense_table_data-row-6-col-0", "Jul")
      assert has_element?(view, "#income_expense_table_data-row-6-col-1", "$0.00")
      assert has_element?(view, "#income_expense_table_data-row-6-col-2", "$0.00")
      assert has_element?(view, "#income_expense_table_data-row-7-col-0", "Aug")
      assert has_element?(view, "#income_expense_table_data-row-7-col-1", "$0.00")
      assert has_element?(view, "#income_expense_table_data-row-7-col-2", "$0.00")
      assert has_element?(view, "#income_expense_table_data-row-8-col-0", "Sep")
      assert has_element?(view, "#income_expense_table_data-row-8-col-1", "$1,500.00")
      assert has_element?(view, "#income_expense_table_data-row-8-col-2", "$500.00")
      assert has_element?(view, "#income_expense_table_data-row-9-col-0", "Oct")
      assert has_element?(view, "#income_expense_table_data-row-9-col-1", "$0.00")
      assert has_element?(view, "#income_expense_table_data-row-9-col-2", "$60.00")
      assert has_element?(view, "#income_expense_table_data-row-10-col-0", "Nov")
      assert has_element?(view, "#income_expense_table_data-row-10-col-1", "$0.00")
      assert has_element?(view, "#income_expense_table_data-row-10-col-2", "$0.00")
      assert has_element?(view, "#income_expense_table_data-row-11-col-0", "Dec")
      assert has_element?(view, "#income_expense_table_data-row-11-col-1", "$0.00")
      assert has_element?(view, "#income_expense_table_data-row-11-col-2", "$0.00")
      assert has_element?(view, "#income_expense_table_data-footer-col-0", "Total")
      assert has_element?(view, "#income_expense_table_data-footer-col-1", "$1,500.00")
      assert has_element?(view, "#income_expense_table_data-footer-col-2", "$560.00")

      # profit / loss
      assert has_element?(view, "#profit_loss_table_data")
      assert has_element?(view, "#profit_loss_table_data-row-0-col-0", "Jan")
      assert has_element?(view, "#profit_loss_table_data-row-0-col-1", "$0.00")
      assert has_element?(view, "#profit_loss_table_data-row-1-col-0", "Feb")
      assert has_element?(view, "#profit_loss_table_data-row-1-col-1", "$0.00")
      assert has_element?(view, "#profit_loss_table_data-row-2-col-0", "Mar")
      assert has_element?(view, "#profit_loss_table_data-row-2-col-1", "$0.00")
      assert has_element?(view, "#profit_loss_table_data-row-3-col-0", "Apr")
      assert has_element?(view, "#profit_loss_table_data-row-3-col-1", "$0.00")
      assert has_element?(view, "#profit_loss_table_data-row-4-col-0", "May")
      assert has_element?(view, "#profit_loss_table_data-row-4-col-1", "$0.00")
      assert has_element?(view, "#profit_loss_table_data-row-5-col-0", "Jun")
      assert has_element?(view, "#profit_loss_table_data-row-5-col-1", "$0.00")
      assert has_element?(view, "#profit_loss_table_data-row-6-col-0", "Jul")
      assert has_element?(view, "#profit_loss_table_data-row-6-col-1", "$0.00")
      assert has_element?(view, "#profit_loss_table_data-row-7-col-0", "Aug")
      assert has_element?(view, "#profit_loss_table_data-row-7-col-1", "$0.00")
      assert has_element?(view, "#profit_loss_table_data-row-8-col-0", "Sep")
      assert has_element?(view, "#profit_loss_table_data-row-8-col-1", "$1,000.00")
      assert has_element?(view, "#profit_loss_table_data-row-9-col-0", "Oct")
      assert has_element?(view, "#profit_loss_table_data-row-9-col-1", "-$60.00")
      assert has_element?(view, "#profit_loss_table_data-row-10-col-0", "Nov")
      assert has_element?(view, "#profit_loss_table_data-row-10-col-1", "$0.00")
      assert has_element?(view, "#profit_loss_table_data-row-11-col-0", "Dec")
      assert has_element?(view, "#profit_loss_table_data-row-11-col-1", "$0.00")
      assert has_element?(view, "#profit_loss_table_data-footer-col-0", "Total")
      assert has_element?(view, "#profit_loss_table_data-footer-col-1", "$940.00")
    end

    test "pushes yearly transactions when filtered to all", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/reports")

      view
      |> form("#date_options", %{"date_options_form" => %{"date_option" => "all"}})
      |> render_change()

      expected_labels = [2019, 2020]

      expected_income = [decimal(1500), decimal(15000)]
      expected_expense = [decimal(560), decimal(780)]
      expected_profit = [decimal(940), decimal(14220)]
      expected_loss = [decimal(0), decimal(0)]

      assert_push_event(view, :income_expense_chart_update, %{
        labels: ^expected_labels,
        datasets: [
          %{label: "Income", data: ^expected_income},
          %{label: "Expense", data: ^expected_expense}
        ]
      })

      assert_push_event(view, :profit_loss_chart_update, %{
        labels: ^expected_labels,
        datasets: [
          %{label: "Profit", data: ^expected_profit},
          %{label: "Loss", data: ^expected_loss}
        ]
      })
    end

    test "loads yearly details when filtered to all", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/reports")

      view
      |> form("#date_options", %{"date_options_form" => %{"date_option" => "all"}})
      |> render_change()

      # income / expense
      assert has_element?(view, "#income_expense_table_data")
      assert has_element?(view, "#income_expense_table_data-row-0-col-0", "2019")
      assert has_element?(view, "#income_expense_table_data-row-0-col-1", "$1,500.00")
      assert has_element?(view, "#income_expense_table_data-row-0-col-2", "$560.00")
      assert has_element?(view, "#income_expense_table_data-row-1-col-0", "2020")
      assert has_element?(view, "#income_expense_table_data-row-1-col-1", "$15,000.00")
      assert has_element?(view, "#income_expense_table_data-row-1-col-2", "$780.00")
      assert has_element?(view, "#income_expense_table_data-footer-col-0", "Total")
      assert has_element?(view, "#income_expense_table_data-footer-col-1", "$16,500.00")
      assert has_element?(view, "#income_expense_table_data-footer-col-2", "$1,340.00")

      # profit / loss
      assert has_element?(view, "#profit_loss_table_data")
      assert has_element?(view, "#profit_loss_table_data-row-0-col-0", "2019")
      assert has_element?(view, "#profit_loss_table_data-row-0-col-1", "$940.00")
      assert has_element?(view, "#profit_loss_table_data-row-1-col-0", "2020")
      assert has_element?(view, "#profit_loss_table_data-row-1-col-1", "$14,220.00")
      assert has_element?(view, "#profit_loss_table_data-footer-col-0", "Total")
      assert has_element?(view, "#profit_loss_table_data-footer-col-1", "$15,160.00")
    end

    test "with no transactions doesn't crash", %{conn: conn} do
      Repo.delete_all(Transaction)
      # just ensure the LV loads without crashing
      {:ok, _view, _html} = live(conn, ~p"/reports")
    end
  end
end
