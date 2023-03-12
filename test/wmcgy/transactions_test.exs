defmodule Wmcgy.TransactionsTest do
  use WmcgyTest.DataCase, async: true

  import WmcgyTest.AccountsFixtures
  import WmcgyTest.CategoriesFixtures
  import WmcgyTest.TransactionsFixtures

  alias Wmcgy.Query
  alias Wmcgy.Repo
  alias Wmcgy.Transactions
  alias WmcgySchema.Transaction

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

  describe "get_transaction!/2" do
    setup do
      user = user_fixture()
      category = category_fixture(user)
      transaction = transaction_fixture(user, category)

      %{user: user, transaction: transaction}
    end

    test "returns the transaction when it is owned by the current user", %{
      user: user,
      transaction: transaction
    } do
      assert transaction == Transactions.get_transaction!(user, transaction.id)
    end

    test "raises when the transaction is not owned by the current user", %{
      transaction: transaction
    } do
      some_other_user = user_fixture()

      assert_raise Ecto.NoResultsError, fn ->
        Transactions.get_transaction!(some_other_user, transaction.id)
      end
    end

    test "raises when the transaction does not exist", %{user: user} do
      assert_raise Ecto.NoResultsError, fn ->
        Transactions.get_transaction!(user, -1)
      end
    end
  end

  describe "create_transaction/3" do
    setup do
      user = user_fixture()
      category = category_fixture(user)

      [
        user: user,
        category: category
      ]
    end

    test "with valid data creates a transaction", %{user: user, category: category} do
      attrs = %{
        category_id: category.id,
        description: "my transaction",
        date: ~D[2022-01-22],
        amount: decimal(2.57),
        type: :income
      }

      assert {:ok, %Transaction{} = transaction} = Transactions.create_transaction(user, attrs)

      assert transaction.user_id == user.id
      assert transaction.category_id == category.id
      assert transaction.description == "my transaction"
      assert transaction.date == ~D[2022-01-22]
      assert transaction.amount == decimal(2.57)
      assert transaction.type == :income
    end

    test "when transaction is an expense, amount is inserted as a negative value", %{
      user: user,
      category: category
    } do
      attrs = %{
        category_id: category.id,
        description: "my transaction",
        date: ~D[2022-01-22],
        amount: decimal(2.57),
        type: :expense
      }

      assert {:ok, %Transaction{} = transaction} = Transactions.create_transaction(user, attrs)

      assert transaction.amount == decimal(-2.57)
      assert transaction.type == :expense
    end

    test "when transaction is an expense, and amount is negative already, does not flip amount",
         %{user: user, category: category} do
      attrs = %{
        category_id: category.id,
        description: "my transaction",
        date: ~D[2022-01-22],
        amount: decimal(-2.57),
        type: :expense
      }

      assert {:ok, %Transaction{} = transaction} = Transactions.create_transaction(user, attrs)

      assert transaction.amount == decimal(-2.57)
      assert transaction.type == :expense
    end

    test "when transaction is not an expense, amount is inserted as a positive value", %{
      user: user,
      category: category
    } do
      attrs = %{
        category_id: category.id,
        description: "my transaction",
        date: ~D[2022-01-22],
        amount: decimal(-2.57),
        type: :income
      }

      assert {:ok, %Transaction{} = transaction} = Transactions.create_transaction(user, attrs)

      assert transaction.amount == decimal(2.57)
      assert transaction.type == :income
    end

    test "with invalid data throws a DB error", %{user: user} do
      assert_raise Postgrex.Error, fn ->
        Transactions.create_transaction(user, %{})
      end
    end
  end

  describe "update_transaction/3" do
    setup do
      user = user_fixture()

      category_1 = category_fixture(user)
      category_2 = category_fixture(user)

      transaction = transaction_fixture(user, category_1)

      [
        user: user,
        category_2: category_2,
        transaction: transaction
      ]
    end

    test "with valid attributes updates the transaction", %{
      user: user,
      category_2: category_2,
      transaction: transaction
    } do
      update_attrs = %{
        category_id: category_2.id,
        description: "my updated transaction",
        date: ~D[2002-03-16],
        amount: decimal(232.63),
        type: :income
      }

      assert {:ok, %Transaction{} = transaction} =
               Transactions.update_transaction(transaction, update_attrs)

      assert transaction.user_id == user.id
      assert transaction.category_id == category_2.id
      assert transaction.description == "my updated transaction"
      assert transaction.date == ~D[2002-03-16]
      assert transaction.amount == decimal(232.63)
      assert transaction.type == :income
    end

    test "when transaction is an expense, amount is inserted as a negative value", %{
      transaction: transaction
    } do
      attrs = %{
        amount: decimal(2.57),
        type: :expense
      }

      assert {:ok, %Transaction{} = transaction} =
               Transactions.update_transaction(transaction, attrs)

      assert transaction.amount == decimal(-2.57)
      assert transaction.type == :expense
    end

    test "when transaction is not an expense, amount is inserted as a positive value", %{
      transaction: transaction
    } do
      attrs = %{
        amount: decimal(-2.57),
        type: :income
      }

      assert {:ok, %Transaction{} = transaction} =
               Transactions.update_transaction(transaction, attrs)

      assert transaction.amount == decimal(2.57)
      assert transaction.type == :income
    end

    test "with invalid data throws a DB error", %{
      transaction: transaction
    } do
      invalid_update_attrs = %{
        description: "",
        date: nil,
        type: nil
      }

      assert_raise Postgrex.Error, fn ->
        Transactions.update_transaction(transaction, invalid_update_attrs)
      end
    end
  end

  describe "delete_transaction/2" do
    setup do
      user_1 = user_fixture()
      user_2 = user_fixture()
      category = category_fixture(user_1)
      transaction = transaction_fixture(user_1, category)

      %{user_1: user_1, user_2: user_2, transaction: transaction}
    end

    test "when transaction exists and is owned by current user it will be deleted", %{
      user_1: user,
      transaction: transaction
    } do
      assert {:ok, _transaction} = Transactions.delete_transaction(user, transaction.id)

      refute Query.Transaction.for_user(user) |> Repo.get(transaction.id)
    end

    test "when transaction is not owned by current user it will not be deleted", %{
      user_1: user_1,
      user_2: user_2,
      transaction: transaction
    } do
      assert_raise Ecto.NoResultsError, fn ->
        Transactions.delete_transaction(user_2, transaction.id)
      end

      assert Query.Transaction.for_user(user_1) |> Repo.get(transaction.id)
    end

    test "raises an error when the transaction does not exist", %{user_1: user} do
      assert_raise Ecto.NoResultsError, fn ->
        Transactions.delete_transaction(user, -1)
      end
    end
  end
end
