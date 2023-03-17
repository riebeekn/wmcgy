defmodule WmcgyUtilities.ParamsTest do
  use WmcgyTest.DataCase

  alias Ecto.Changeset
  alias WmcgyUtilities.Params.{Category, Transaction}

  describe "keys/0 - Category" do
    test "returns category keys" do
      assert [:name] == Category.keys()
    end
  end

  describe "normalize_parameters/2 - Category" do
    test "returns an error when name is missing" do
      assert {:error, %Changeset{} = changeset} = Category.normalize_parameters(%{}, :new)

      assert %{
               name: ["can't be blank"]
             } == errors_on(changeset)
    end

    test "returns an error when name is too short" do
      assert {:error, %Changeset{} = changeset} =
               Category.normalize_parameters(%{name: "Gr"}, :new)

      assert %{
               name: ["should be at least 3 character(s)"]
             } == errors_on(changeset)
    end

    test "returns an error when name is too long" do
      assert {:error, %Changeset{} = changeset} =
               Category.normalize_parameters(%{name: String.duplicate("a", 101)}, :new)

      assert %{
               name: ["should be at most 100 character(s)"]
             } == errors_on(changeset)
    end

    test "returns a map on successful normalization" do
      assert {:ok, %{name: "Groceries"}} ==
               Category.normalize_parameters(%{name: "Groceries"}, :new)
    end
  end

  describe "keys/0 - Transaction" do
    test "returns transaction keys" do
      assert [:amount, :category_id, :date, :description, :type] == Transaction.keys()
    end
  end

  describe "normalize_parameters/2 - Transaction" do
    test "returns an error when required fields missing" do
      assert {:error, %Changeset{} = changeset} = Transaction.normalize_parameters(%{}, :new)

      assert %{
               amount: ["can't be blank"],
               category_id: ["can't be blank"],
               date: ["can't be blank"],
               description: ["can't be blank"],
               type: ["can't be blank"]
             } == errors_on(changeset)
    end

    test "returns an error when date is invalid" do
      assert {:error, %Changeset{} = changeset} =
               Transaction.normalize_parameters(
                 %{
                   "amount" => "123",
                   "category_id" => "1",
                   "date" => "bad date",
                   "description" => "some description",
                   "type" => "expense"
                 },
                 :new
               )

      assert %{date: ["is invalid"]} == errors_on(changeset)
    end

    test "returns an error when description is too long" do
      assert {:error, %Changeset{} = changeset} =
               Transaction.normalize_parameters(
                 %{
                   "amount" => "123",
                   "category_id" => "1",
                   "date" => ~D[2000-01-17],
                   "description" => String.duplicate("a", 256),
                   "type" => "income"
                 },
                 :new
               )

      assert %{description: ["should be at most 255 character(s)"]} == errors_on(changeset)
    end

    test "returns a map and rounds / pads the amount on successful normalization" do
      assert {:ok,
              %{
                amount: decimal(123.55),
                category_id: 1,
                date: ~D[2000-01-17],
                description: "some description",
                type: :expense
              }} ==
               Transaction.normalize_parameters(
                 %{
                   "amount" => "123.548976",
                   "category_id" => "1",
                   "date" => "2000-01-17",
                   "description" => "some description",
                   "type" => "expense"
                 },
                 :new
               )
    end
  end
end
