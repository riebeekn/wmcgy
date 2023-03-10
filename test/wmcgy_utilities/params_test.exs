defmodule WmcgyUtilities.ParamsTest do
  use WmcgyTest.DataCase

  alias Ecto.Changeset
  alias WmcgyUtilities.Params.Category

  describe "keys/0 - Category" do
    test "returns category keys" do
      assert Category.keys() == [:name]
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
end
