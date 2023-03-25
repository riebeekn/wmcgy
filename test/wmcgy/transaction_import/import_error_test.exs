defmodule Wmcgy.TransactionImport.ImportErrorTest do
  use ExUnit.Case

  alias Wmcgy.TransactionImport.ImportError
  alias WmcgySchema.Transaction

  describe "new/2" do
    setup do
      changeset =
        %Transaction{}
        |> Ecto.Changeset.cast(
          %{description: "", date: "", amount: "", type: "", external_id: ""},
          [:description, :date, :amount, :type, :external_id]
        )
        |> Ecto.Changeset.validate_required([
          :description,
          :date,
          :amount,
          :type,
          :external_id
        ])

      %{changeset: changeset}
    end

    test "creates an ImportError struct with a formatted error message", %{changeset: changeset} do
      assert %ImportError{
               row_number: 132,
               message:
                 "Amount: can't be blank, Date: can't be blank, Description: can't be blank, Id: can't be blank, Type: can't be blank"
             } == ImportError.new(changeset, 132)
    end
  end
end
