defmodule Wmcgy.CategoriesTest do
  use WmcgyTest.DataCase, async: true

  import WmcgyTest.AccountsFixtures
  import WmcgyTest.CategoriesFixtures
  import WmcgyTest.TransactionsFixtures

  alias Wmcgy.Categories
  alias Wmcgy.Query
  alias WmcgySchema.Category

  describe "list_categories/1" do
    setup do
      user_1 = user_fixture()
      user_2 = user_fixture()
      category_1 = category_fixture(user_1, "second category after ordering")
      category_2 = category_fixture(user_1, "first category after ordering")
      _category_3 = category_fixture(user_2)

      [
        user: user_1,
        category_1: category_1,
        category_2: category_2
      ]
    end

    test "returns all categories for the specified user ordered by category name", %{
      user: user,
      category_1: category_1,
      category_2: category_2
    } do
      categories = Categories.list_categories(user)

      assert Enum.count(categories) == 2
      assert categories == [category_2, category_1]
    end
  end

  describe "get_category!/2" do
    setup do
      user_1 = user_fixture()
      user_2 = user_fixture()
      category_1 = category_fixture(user_1, "second category after ordering")
      category_2 = category_fixture(user_2, "first category after ordering")

      [
        user: user_1,
        category_1: category_1,
        category_2: category_2
      ]
    end

    test "returns the category when it exists", %{user: user, category_1: category_1} do
      assert category_1 == Categories.get_category!(user, category_1.id)
    end

    test "does not return the category and raises when it belongs to another user", %{
      user: user,
      category_2: category_2
    } do
      assert_raise Ecto.NoResultsError, fn ->
        Categories.get_category!(user, category_2.id)
      end
    end

    test "raises an error when the category does not exist", %{user: user} do
      assert_raise Ecto.NoResultsError, fn ->
        Categories.get_category!(user, -1)
      end
    end
  end

  describe "create_category/2" do
    test "with valid data creates a category" do
      user = user_fixture()

      assert {:ok, %Category{} = category} =
               Categories.create_category(user, "some category name")

      assert category.name == "some category name"
      assert category.user_id == user.id
    end

    test "allows for duplicate names as long as they are across different users" do
      user_1 = user_fixture()
      user_2 = user_fixture()
      category_fixture(user_2, "some category name")

      assert {:ok, %Category{} = category} =
               Categories.create_category(user_1, "some category name")

      assert category.name == "some category name"
    end

    test "does not allow duplicate names for the same user even if casing is different" do
      # arrange
      user_1 = user_fixture()
      category_fixture(user_1, "some category name")

      # act / assert
      assert {:error, %Ecto.Changeset{} = changeset} =
               Categories.create_category(user_1, "some category name" |> String.upcase())

      assert errors_on(changeset) == %{name: ["has already been taken"]}
    end
  end

  describe "update_category/2" do
    setup do
      user = user_fixture()
      category = category_fixture(user, "some category")

      [
        user: user,
        category: category
      ]
    end

    test "with valid attributes updates the category", %{category: category} do
      assert {:ok, category} = Categories.update_category(category, "a new name")

      assert category.name == "a new name"
    end

    test "does not update when the update would result in a duplicate name", %{
      user: user,
      category: category
    } do
      category_fixture(user, "a name")

      assert {:error, %Ecto.Changeset{} = changeset} =
               Categories.update_category(category, "a name")

      assert errors_on(changeset) == %{name: ["has already been taken"]}
    end
  end

  describe "delete_category/2" do
    setup do
      user_1 = user_fixture()
      user_2 = user_fixture()
      category = category_fixture(user_1, "category belonging to user 1")

      [
        user_1: user_1,
        user_2: user_2,
        category: category
      ]
    end

    test "when category exists and is owned by the current user it will be deleted", %{
      user_1: user,
      category: category
    } do
      assert {:ok, _category} = Categories.delete_category(user, category.id)

      refute Query.Categories.for_user(user) |> Repo.get(category.id)
    end

    test "when category is not owned by the current user it will not be deleted", %{
      user_1: user_1,
      user_2: user_2,
      category: category
    } do
      assert_raise Ecto.NoResultsError, fn ->
        Categories.delete_category(user_2, category.id)
      end

      assert Query.Categories.for_user(user_1) |> Repo.get(category.id)
    end

    test "when a category has transactions associated with it, it won't be deleted", %{
      user_1: user,
      category: category
    } do
      transaction_fixture(user, category)

      assert {:error, %Ecto.Changeset{} = changeset} =
               Categories.delete_category(user, category.id)

      assert errors_on(changeset) == %{transactions: ["category in use"]}
    end

    test "raises an error when the category does not exist", %{user_1: user} do
      assert_raise Ecto.NoResultsError, fn ->
        Categories.delete_category(user, -1)
      end
    end
  end

  describe "has_categories?/1" do
    setup do
      user_1 = user_fixture()
      user_2 = user_fixture()
      category_fixture(user_1, "some category")

      [
        user_1: user_1,
        user_2: user_2
      ]
    end

    test "returns true when the user has created one or more categories", %{user_1: user} do
      assert Categories.has_categories?(user)
    end

    test "returns false when user has not created a category", %{user_2: user} do
      refute Categories.has_categories?(user)
    end
  end
end
