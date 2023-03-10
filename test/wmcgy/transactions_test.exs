defmodule Wmcgy.TransactionsTest do
  use WmcgyTest.DataCase, async: true

  import WmcgyTest.AccountsFixtures
  import WmcgyTest.CategoriesFixtures
  import WmcgyTest.TransactionsFixtures

  alias Wmcgy.Repo
  alias Wmcgy.Transactions

  describe "list_transactions/2" do
    setup do
      user_1 = user_fixture()
      user_2 = user_fixture()

      category_1 = category_fixture(user_1, "first category")
      category_2 = category_fixture(user_1, "second category")
      category_3 = category_fixture(user_1, "third category")

      two_days_ago = Date.utc_today() |> Date.add(-2)
      three_days_ago = Date.utc_today() |> Date.add(-3)
      four_days_ago = Date.utc_today() |> Date.add(-4)
      transaction_1 = transaction_fixture(user_1, category_2, %{date: three_days_ago, amount: 14})
      transaction_2 = transaction_fixture(user_1, category_1, %{date: four_days_ago, amount: 12})
      transaction_3 = transaction_fixture(user_1, category_3, %{date: two_days_ago, amount: 3})
      transaction_4 = transaction_fixture(user_1, category_2, %{date: two_days_ago, amount: 4})
      _transaction_5 = transaction_fixture(user_2, category_fixture(user_2))

      [
        user: user_1,
        transaction_1: transaction_1,
        transaction_2: transaction_2,
        transaction_3: transaction_3,
        transaction_4: transaction_4
      ]
    end

    test "returns all transactions for the specified user ordered by the transaction date, then id desc",
         %{
           user: user,
           transaction_1: transaction_1,
           transaction_2: transaction_2,
           transaction_3: transaction_3,
           transaction_4: transaction_4
         } do
      transactions = Transactions.list_transactions(user)

      assert transactions.page_number == 1
      assert transactions.page_size == 30
      assert transactions.total_entries == 4
      assert transactions.total_pages == 1

      assert transactions.entries == [
               transaction_4 |> Repo.preload(:category),
               transaction_3 |> Repo.preload(:category),
               transaction_1 |> Repo.preload(:category),
               transaction_2 |> Repo.preload(:category)
             ]
    end

    test "can specify sort field and direction", %{
      user: user,
      transaction_1: transaction_1,
      transaction_2: transaction_2,
      transaction_3: transaction_3,
      transaction_4: transaction_4
    } do
      transactions = Transactions.list_transactions(user, sort_field: :amount)

      assert transactions.entries == [
               transaction_1 |> Repo.preload(:category),
               transaction_2 |> Repo.preload(:category),
               transaction_4 |> Repo.preload(:category),
               transaction_3 |> Repo.preload(:category)
             ]

      transactions = Transactions.list_transactions(user, sort_field: :amount, sort_dir: :asc)

      assert transactions.entries == [
               transaction_3 |> Repo.preload(:category),
               transaction_4 |> Repo.preload(:category),
               transaction_2 |> Repo.preload(:category),
               transaction_1 |> Repo.preload(:category)
             ]

      transactions = Transactions.list_transactions(user, sort_field: :date, sort_dir: :asc)

      assert transactions.entries == [
               transaction_2 |> Repo.preload(:category),
               transaction_1 |> Repo.preload(:category),
               transaction_3 |> Repo.preload(:category),
               transaction_4 |> Repo.preload(:category)
             ]
    end

    test "can sort by secondary table fields (category name)", %{
      user: user,
      transaction_1: transaction_1,
      transaction_2: transaction_2,
      transaction_3: transaction_3,
      transaction_4: transaction_4
    } do
      transactions = Transactions.list_transactions(user, sort_field: :category)

      assert transactions.entries == [
               transaction_3 |> Repo.preload(:category),
               transaction_4 |> Repo.preload(:category),
               transaction_1 |> Repo.preload(:category),
               transaction_2 |> Repo.preload(:category)
             ]
    end

    test "can filter transactions by page and page size", %{
      user: user,
      transaction_3: transaction_3,
      transaction_4: transaction_4
    } do
      transactions = Transactions.list_transactions(user, page: 1, page_size: 1)

      assert transactions.page_number == 1
      assert transactions.page_size == 1
      assert transactions.total_entries == 4
      assert transactions.total_pages == 4

      assert transactions.entries == [transaction_4 |> Repo.preload(:category)]

      transactions = Transactions.list_transactions(user, page: 2, page_size: 1)

      assert transactions.page_number == 2
      assert transactions.page_size == 1
      assert transactions.total_entries == 4
      assert transactions.total_pages == 4

      assert transactions.entries == [transaction_3 |> Repo.preload(:category)]

      transactions = Transactions.list_transactions(user, page: 1, page_size: 2)

      assert transactions.page_number == 1
      assert transactions.page_size == 2
      assert transactions.total_entries == 4
      assert transactions.total_pages == 2

      assert transactions.entries == [
               transaction_4 |> Repo.preload(:category),
               transaction_3 |> Repo.preload(:category)
             ]
    end
  end
end
