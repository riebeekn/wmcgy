defmodule Wmcgy.TransactionImport.ImportProgressTest do
  use ExUnit.Case

  alias Wmcgy.TransactionImport.ImportError
  alias Wmcgy.TransactionImport.ImportProgress
  alias WmcgySchema.Transaction

  describe "handle_event/2" do
    test "increments current row and new record count on created event" do
      assert %ImportProgress{
               current_row: 2,
               duplicate_record_count: 0,
               error_count: 0,
               errors: [],
               invalid_file?: false,
               new_record_count: 1,
               updated_record_count: 0
             } == ImportProgress.handle_event({:ok, :created}, %ImportProgress{})
    end

    test "increments current row and updated record count on updated event" do
      assert %ImportProgress{
               current_row: 2,
               duplicate_record_count: 0,
               error_count: 0,
               errors: [],
               invalid_file?: false,
               new_record_count: 0,
               updated_record_count: 1
             } == ImportProgress.handle_event({:ok, :updated}, %ImportProgress{})
    end

    test "increments current row and duplicate record count on noop event" do
      assert %ImportProgress{
               current_row: 2,
               duplicate_record_count: 1,
               error_count: 0,
               errors: [],
               invalid_file?: false,
               new_record_count: 0,
               updated_record_count: 0
             } == ImportProgress.handle_event({:ok, :noop}, %ImportProgress{})
    end

    test "increments current row and new error count on error event" do
      changeset =
        %Transaction{}
        |> Ecto.Changeset.cast(%{description: ""}, [:description])
        |> Ecto.Changeset.validate_required([:description])

      assert %ImportProgress{
               current_row: 2,
               duplicate_record_count: 0,
               error_count: 1,
               errors: [%ImportError{message: "Description: can't be blank", row_number: 2}],
               invalid_file?: false,
               new_record_count: 0,
               updated_record_count: 0
             } == ImportProgress.handle_event({:error, changeset}, %ImportProgress{})
    end
  end
end
