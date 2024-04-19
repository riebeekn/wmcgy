defmodule Wmcgy.TransactionImportTest do
  use WmcgyTest.DataCase, async: true

  import WmcgyTest.AccountsFixtures

  alias Wmcgy.TransactionImport
  alias Wmcgy.TransactionImport.{ImportError, ImportProgress}
  alias WmcgySchema.{Category, Transaction}

  @valid_csv_header ["ID", "Date", "Category", "Description", "Amount"]

  describe "import_transactions/4" do
    setup do
      %{user: user_fixture()}
    end

    test "performs no imports with a bad header", %{user: user} do
      assert %ImportProgress{
               new_record_count: 0,
               updated_record_count: 0,
               duplicate_record_count: 0,
               error_count: 0,
               errors: [],
               invalid_file?: true,
               current_row: 1
             } ==
               TransactionImport.import_transactions(
                 %ImportProgress{},
                 user,
                 ["This", "is", "not", "a", "valid", "header!"],
                 []
               )

      assert Repo.aggregate(Category, :count) == 0
      assert Repo.aggregate(Transaction, :count) == 0
    end

    test "does nothing with no data", %{user: user} do
      assert %ImportProgress{
               new_record_count: 0,
               updated_record_count: 0,
               duplicate_record_count: 0,
               error_count: 0,
               errors: [],
               invalid_file?: false,
               current_row: 1
             } ==
               TransactionImport.import_transactions(
                 %ImportProgress{},
                 user,
                 @valid_csv_header,
                 []
               )
    end

    # 1 new record, 1 invalid record (missing fields)
    @batch_1 [
      ["ext_123", "Aug 12, 2019", "Groceries", "", "-124.56"],
      ["", "", "Utilities", "", ""]
    ]

    # 2 new records
    @batch_2 [
      ["ext_234", "Aug 31, 2019", "Pay", "August pay", "2300.00"],
      ["ext_345", "Sep 01, 2019", "Utils", "Phone bill", "-50.65"]
    ]

    # 1 duplicate record, 1 updated record
    @batch_3 [
      ["ext_234", "Aug 31, 2019", "Pay", "August pay", "2300.00"],
      ["ext_345", "Sep 01, 2019", "Utils", "Phone bill", "-150.65"]
    ]

    # 1 duplicate record, 1 updated record
    @batch_4 [
      ["ext_234", "Aug 31, 2019", "Pay", "August pay", "2300.00"],
      ["ext_234", "Aug 31, 2019", "Pay", "August pay", "2400.00"]
    ]

    # 1 invalid record (missing category), 1 new record
    @batch_5 [
      ["ext_456", "Sep 02, 2019", "", "Heating bill", "-56.78"],
      ["ext_567", "Sep 03, 2019", "Entertainment", "Dinner out", "-54.00"]
    ]

    # 1 updated record, 1 invalid record (category too short)
    @batch_6 [
      ["ext_567", "Sep 03, 2019", "Entertainment", "Dinner out", "-154.00"],
      ["ext_678", "Sep 04, 2019", "En", "Dinner out", "-154.00"]
    ]

    # 1 updated record, 1 invalid record (bad date)
    @batch_7 [
      ["ext_567", "Sep 03, 2019", "Ordering In / Dining Out", "Dinner out", "-154.00"],
      ["ext_567", "Sep 33, 2019", "Ordering In / Dining Out", "Dinner out", "-154.00"]
    ]

    test "imports transactions", %{user: user} do
      import_progress =
        %ImportProgress{}
        |> TransactionImport.import_transactions(user, @valid_csv_header, @batch_1)
        |> TransactionImport.import_transactions(user, @valid_csv_header, @batch_2)
        |> TransactionImport.import_transactions(user, @valid_csv_header, @batch_3)
        |> TransactionImport.import_transactions(user, @valid_csv_header, @batch_4)
        |> TransactionImport.import_transactions(user, @valid_csv_header, @batch_5)
        |> TransactionImport.import_transactions(user, @valid_csv_header, @batch_6)
        |> TransactionImport.import_transactions(user, @valid_csv_header, @batch_7)

      assert %ImportProgress{
               new_record_count: 4,
               updated_record_count: 4,
               duplicate_record_count: 2,
               error_count: 4,
               errors: [
                 %ImportError{
                   message: "Date: can't be blank, Amount: can't be blank, Id: can't be blank",
                   row_number: 3
                 },
                 %ImportError{message: "Category name: can't be blank", row_number: 10},
                 %ImportError{
                   message: "Category name: should be at least 3 character(s)",
                   row_number: 13
                 },
                 %ImportError{message: "Date: is invalid", row_number: 15}
               ],
               invalid_file?: false,
               current_row: 15
             } == import_progress

      assert Repo.aggregate(Transaction, :count) == 4
      assert Repo.aggregate(Category, :count) == 5
    end
  end
end
