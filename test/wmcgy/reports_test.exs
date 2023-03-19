defmodule Wmcgy.ReportsTest do
  use WmcgyTest.DataCase, async: true

  import WmcgyTest.AccountsFixtures
  import WmcgyTest.CategoriesFixtures
  import WmcgyTest.TransactionsFixtures

  alias Wmcgy.Reports
  alias Wmcgy.Reports.CategoryReport
  alias Wmcgy.Reports.MonthlyIncomeExpenseReport
  alias Wmcgy.Reports.YearlyIncomeExpenseReport

  describe "income_by_category_report/2" do
    setup do
      user_1 = user_fixture()
      user_2 = user_fixture()

      category_1 = category_fixture(user_1, "Misc")
      category_2 = category_fixture(user_1, "Pay")
      category_for_other_user = category_fixture(user_2)

      today = Date.utc_today()
      two_days_ago = today |> Date.add(-2)
      three_days_ago = today |> Date.add(-3)
      four_days_ago = today |> Date.add(-4)

      # category 1 transactions
      transaction_fixture(user_1, category_1, %{amount: 23.56, date: today})
      transaction_fixture(user_1, category_1, %{amount: 33.78, date: two_days_ago})
      transaction_fixture(user_1, category_1, %{amount: -10.99, date: three_days_ago})
      transaction_fixture(user_1, category_1, %{amount: 12.99, date: today})
      transaction_fixture(user_1, category_1, %{amount: 37.45, date: two_days_ago})
      transaction_fixture(user_1, category_1, %{amount: 137.45, date: four_days_ago})
      transaction_fixture(user_1, category_1, %{amount: -2.44, date: three_days_ago})

      # category 2 transactions
      transaction_fixture(user_1, category_2, %{amount: 18.75, date: today})
      transaction_fixture(user_1, category_2, %{amount: 15.66, date: two_days_ago})
      transaction_fixture(user_1, category_2, %{amount: -123.76, date: three_days_ago})

      # transaction_for_other_user
      transaction_fixture(user_2, category_for_other_user)

      [
        user: user_1,
        today: today,
        two_days_ago: two_days_ago,
        three_days_ago: three_days_ago
      ]
    end

    test "returns income grouped by category, ordered by category", %{user: user} do
      assert %CategoryReport{
               start_date: nil,
               end_date: nil,
               type: :income,
               total_for_all_categories: decimal(279.64),
               line_items: [
                 %CategoryReport.LineItem{
                   category_name: "Misc",
                   amount: decimal(245.23),
                   percentage: decimal(87.7)
                 },
                 %CategoryReport.LineItem{
                   category_name: "Pay",
                   amount: decimal(34.41),
                   percentage: decimal(12.3)
                 }
               ]
             } == Reports.income_by_category_report(user)
    end

    test "scopes by from date correctly", %{user: user, today: today} do
      assert %CategoryReport{
               start_date: today,
               end_date: nil,
               type: :income,
               total_for_all_categories: decimal("55.30"),
               line_items: [
                 %CategoryReport.LineItem{
                   category_name: "Misc",
                   amount: decimal(36.55),
                   percentage: decimal(66.1)
                 },
                 %CategoryReport.LineItem{
                   category_name: "Pay",
                   amount: decimal(18.75),
                   percentage: decimal(33.9)
                 }
               ]
             } == Reports.income_by_category_report(user, start_date: today)
    end

    test "scopes by to date correctly", %{user: user, two_days_ago: two_days_ago} do
      assert %CategoryReport{
               start_date: nil,
               end_date: two_days_ago,
               type: :income,
               total_for_all_categories: decimal(224.34),
               line_items: [
                 %CategoryReport.LineItem{
                   category_name: "Misc",
                   amount: decimal(208.68),
                   percentage: decimal(93.0)
                 },
                 %CategoryReport.LineItem{
                   category_name: "Pay",
                   amount: decimal(15.66),
                   percentage: decimal(7.0)
                 }
               ]
             } == Reports.income_by_category_report(user, end_date: two_days_ago)
    end

    test "scopes by from and to date correctly", %{
      user: user,
      two_days_ago: two_days_ago,
      three_days_ago: three_days_ago
    } do
      assert %CategoryReport{
               start_date: three_days_ago,
               end_date: two_days_ago,
               type: :income,
               total_for_all_categories: decimal(86.89),
               line_items: [
                 %CategoryReport.LineItem{
                   category_name: "Misc",
                   amount: decimal(71.23),
                   percentage: decimal(82.0)
                 },
                 %CategoryReport.LineItem{
                   category_name: "Pay",
                   amount: decimal(15.66),
                   percentage: decimal(18.0)
                 }
               ]
             } ==
               Reports.income_by_category_report(user,
                 start_date: three_days_ago,
                 end_date: two_days_ago
               )
    end

    test "return no line items when dates out of scope", %{user: user} do
      assert %Wmcgy.Reports.CategoryReport{
               start_date: Date.utc_today() |> Date.add(12),
               line_items: [],
               end_date: Date.utc_today() |> Date.add(12),
               total_for_all_categories: decimal("0.00"),
               type: :income
             } ==
               Reports.income_by_category_report(user,
                 start_date: Date.utc_today() |> Date.add(12),
                 end_date: Date.utc_today() |> Date.add(12)
               )
    end
  end

  describe "expense_by_category_report/2" do
    setup do
      user_1 = user_fixture()
      user_2 = user_fixture()

      category_1 = category_fixture(user_1, "Entertainment")
      category_2 = category_fixture(user_1, "Groceries")
      category_for_other_user = category_fixture(user_2)

      today = Date.utc_today()
      two_days_ago = today |> Date.add(-2)
      three_days_ago = today |> Date.add(-3)
      four_days_ago = today |> Date.add(-4)

      # category 1 transactions
      transaction_fixture(user_1, category_1, %{amount: -23.56, date: today})
      transaction_fixture(user_1, category_1, %{amount: -33.78, date: two_days_ago})
      transaction_fixture(user_1, category_1, %{amount: 10.99, date: three_days_ago})
      transaction_fixture(user_1, category_1, %{amount: -12.99, date: today})
      transaction_fixture(user_1, category_1, %{amount: -37.45, date: two_days_ago})
      transaction_fixture(user_1, category_1, %{amount: -137.45, date: four_days_ago})
      transaction_fixture(user_1, category_1, %{amount: 2.44, date: three_days_ago})

      # category 2 transactions
      transaction_fixture(user_1, category_2, %{amount: -18.75, date: today})
      transaction_fixture(user_1, category_2, %{amount: -15.66, date: two_days_ago})
      transaction_fixture(user_1, category_2, %{amount: 123.76, date: three_days_ago})

      # transaction_for_other_user
      transaction_fixture(user_2, category_for_other_user)

      [
        user: user_1,
        today: today,
        two_days_ago: two_days_ago,
        three_days_ago: three_days_ago
      ]
    end

    test "returns expense grouped by category, ordered by category", %{user: user} do
      assert %CategoryReport{
               start_date: nil,
               end_date: nil,
               type: :expense,
               total_for_all_categories: decimal(279.64),
               line_items: [
                 %CategoryReport.LineItem{
                   category_name: "Entertainment",
                   amount: decimal(245.23),
                   percentage: decimal(87.7)
                 },
                 %CategoryReport.LineItem{
                   category_name: "Groceries",
                   amount: decimal(34.41),
                   percentage: decimal(12.3)
                 }
               ]
             } == Reports.expense_by_category_report(user)
    end

    test "scopes by from date correctly", %{user: user, today: today} do
      assert %CategoryReport{
               start_date: today,
               end_date: nil,
               type: :expense,
               total_for_all_categories: decimal("55.30"),
               line_items: [
                 %CategoryReport.LineItem{
                   category_name: "Entertainment",
                   amount: decimal(36.55),
                   percentage: decimal(66.1)
                 },
                 %CategoryReport.LineItem{
                   category_name: "Groceries",
                   amount: decimal(18.75),
                   percentage: decimal(33.9)
                 }
               ]
             } == Reports.expense_by_category_report(user, start_date: today)
    end

    test "scopes by to date correctly", %{user: user, two_days_ago: two_days_ago} do
      assert %CategoryReport{
               start_date: nil,
               end_date: two_days_ago,
               type: :expense,
               total_for_all_categories: decimal(224.34),
               line_items: [
                 %CategoryReport.LineItem{
                   category_name: "Entertainment",
                   amount: decimal(208.68),
                   percentage: decimal(93.0)
                 },
                 %CategoryReport.LineItem{
                   category_name: "Groceries",
                   amount: decimal(15.66),
                   percentage: decimal(7.0)
                 }
               ]
             } == Reports.expense_by_category_report(user, end_date: two_days_ago)
    end

    test "scopes by from and to date correctly", %{
      user: user,
      two_days_ago: two_days_ago,
      three_days_ago: three_days_ago
    } do
      assert %CategoryReport{
               start_date: three_days_ago,
               end_date: two_days_ago,
               type: :expense,
               total_for_all_categories: decimal(86.89),
               line_items: [
                 %CategoryReport.LineItem{
                   category_name: "Entertainment",
                   amount: decimal(71.23),
                   percentage: decimal(82.0)
                 },
                 %CategoryReport.LineItem{
                   category_name: "Groceries",
                   amount: decimal(15.66),
                   percentage: decimal(18.0)
                 }
               ]
             } ==
               Reports.expense_by_category_report(user,
                 start_date: three_days_ago,
                 end_date: two_days_ago
               )
    end

    test "return nothing when dates out of scope", %{user: user} do
      assert %Wmcgy.Reports.CategoryReport{
               start_date: Date.utc_today() |> Date.add(12),
               line_items: [],
               end_date: Date.utc_today() |> Date.add(12),
               total_for_all_categories: decimal("0.00"),
               type: :expense
             } ==
               Reports.expense_by_category_report(user,
                 start_date: Date.utc_today() |> Date.add(12),
                 end_date: Date.utc_today() |> Date.add(12)
               )
    end
  end

  describe "monthly_income_expense_report/5" do
    setup do
      user_1 = user_fixture()
      user_2 = user_fixture()

      category = category_fixture(user_1)
      category_for_other_user = category_fixture(user_2)

      # Dec 2019
      transaction_fixture(user_1, category, %{amount: -2000, date: ~D[2019-12-15]})
      transaction_fixture(user_1, category, %{amount: -3000, date: ~D[2019-12-31]})

      # Jan 2020
      transaction_fixture(user_1, category, %{amount: -100, date: ~D[2020-01-01]})
      transaction_fixture(user_1, category, %{amount: 200, date: ~D[2020-01-25]})

      # Feb
      transaction_fixture(user_1, category, %{amount: -200, date: ~D[2020-02-15]})

      # Apr
      transaction_fixture(user_1, category, %{amount: 1000, date: ~D[2020-04-12]})

      # Transaction for different user
      transaction_fixture(user_2, category_for_other_user, %{amount: -1000, date: ~D[2020-01-01]})

      [
        user: user_1
      ]
    end

    test "returns monthly summary of income and expenses for the passed in period", %{user: user} do
      assert %MonthlyIncomeExpenseReport{
               start_date: ~D[2019-11-01],
               end_date: ~D[2020-05-31],
               expense_total: decimal(5300),
               income_total: decimal(1200),
               profit_loss_total: decimal(-4100),
               line_items: [
                 %MonthlyIncomeExpenseReport.LineItem{
                   expense: decimal(0),
                   income: decimal(0),
                   profit_loss: decimal(0),
                   month: 11,
                   year: 2019
                 },
                 %MonthlyIncomeExpenseReport.LineItem{
                   expense: decimal(5000),
                   income: decimal(0),
                   profit_loss: decimal(-5000),
                   month: 12,
                   year: 2019
                 },
                 %MonthlyIncomeExpenseReport.LineItem{
                   expense: decimal(100),
                   income: decimal(200),
                   profit_loss: decimal(100),
                   month: 1,
                   year: 2020
                 },
                 %MonthlyIncomeExpenseReport.LineItem{
                   expense: decimal(200),
                   income: decimal(0),
                   profit_loss: decimal(-200),
                   month: 2,
                   year: 2020
                 },
                 %MonthlyIncomeExpenseReport.LineItem{
                   expense: decimal(0),
                   income: decimal(0),
                   profit_loss: decimal(0),
                   month: 3,
                   year: 2020
                 },
                 %MonthlyIncomeExpenseReport.LineItem{
                   expense: decimal(0),
                   income: decimal(1000),
                   profit_loss: decimal(1000),
                   month: 4,
                   year: 2020
                 },
                 %MonthlyIncomeExpenseReport.LineItem{
                   expense: decimal(0),
                   income: decimal(0),
                   profit_loss: decimal(0),
                   month: 5,
                   year: 2020
                 }
               ]
             } ==
               Reports.monthly_income_expense_report(user, 2019, 11, 2020, 05)
    end

    test "returns nothing when nothing in range", %{user: user} do
      assert assert %MonthlyIncomeExpenseReport{
                      start_date: ~D[2021-12-01],
                      end_date: ~D[2021-12-31],
                      expense_total: decimal(0),
                      income_total: decimal(0),
                      profit_loss_total: decimal(0),
                      line_items: [
                        %MonthlyIncomeExpenseReport.LineItem{
                          expense: decimal(0),
                          income: decimal(0),
                          profit_loss: decimal(0),
                          month: 12,
                          year: 2021
                        }
                      ]
                    } == Reports.monthly_income_expense_report(user, 2021, 12, 2021, 12)
    end
  end

  describe "yearly_income_expense_report/3" do
    setup do
      user_1 = user_fixture()
      user_2 = user_fixture()

      category = category_fixture(user_1)
      category_for_other_user = category_fixture(user_2)

      # 2018
      transaction_fixture(user_1, category, %{amount: -2000, date: ~D[2018-12-15]})
      transaction_fixture(user_1, category, %{amount: -3000, date: ~D[2018-12-31]})

      # 2020
      transaction_fixture(user_1, category, %{amount: -100, date: ~D[2020-01-01]})
      transaction_fixture(user_1, category, %{amount: 200, date: ~D[2020-01-25]})

      # Feb
      transaction_fixture(user_1, category, %{amount: -200, date: ~D[2020-02-15]})

      # Apr
      transaction_fixture(user_1, category, %{amount: 1000, date: ~D[2020-04-12]})

      # Transaction for different user
      transaction_fixture(user_2, category_for_other_user, %{amount: -1000, date: ~D[2020-01-01]})

      [
        user: user_1
      ]
    end

    test "returns yearly summary of income and expenses for the passed in period", %{user: user} do
      assert %YearlyIncomeExpenseReport{
               start_year: 2018,
               end_year: 2020,
               expense_total: decimal(5300),
               income_total: decimal(1200),
               profit_loss_total: decimal(-4100),
               line_items: [
                 %YearlyIncomeExpenseReport.LineItem{
                   expense: decimal(5000),
                   income: decimal(0),
                   profit_loss: decimal(-5000),
                   year: 2018
                 },
                 %YearlyIncomeExpenseReport.LineItem{
                   expense: decimal(0),
                   income: decimal(0),
                   profit_loss: decimal(0),
                   year: 2019
                 },
                 %YearlyIncomeExpenseReport.LineItem{
                   expense: decimal(300),
                   income: decimal(1200),
                   profit_loss: decimal(900),
                   year: 2020
                 }
               ]
             } ==
               Reports.yearly_income_expense_report(user, 2018, 2020)
    end

    test "returns nothing when nothing in range", %{user: user} do
      assert assert %YearlyIncomeExpenseReport{
                      start_year: 2021,
                      end_year: 2021,
                      expense_total: decimal(0),
                      income_total: decimal(0),
                      profit_loss_total: decimal(0),
                      line_items: [
                        %YearlyIncomeExpenseReport.LineItem{
                          expense: decimal(0),
                          income: decimal(0),
                          profit_loss: decimal(0),
                          year: 2021
                        }
                      ]
                    } == Reports.yearly_income_expense_report(user, 2021, 2021)
    end
  end
end
