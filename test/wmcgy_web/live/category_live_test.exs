defmodule WmcgyWeb.CategoryLiveTest do
  use WmcgyWebTest.ConnCase

  import Phoenix.LiveViewTest
  import WmcgyTest.AccountsFixtures
  import WmcgyTest.CategoriesFixtures

  describe "when not logged in" do
    test "redirects to log in when attempting to access page", %{conn: conn} do
      assert {:error, {:redirect, redirect_map}} = live(conn, ~p"/categories")
      assert redirect_map.to == "/users/log_in"
    end
  end

  describe "List" do
    setup :register_and_log_in_user

    setup(%{user: user}) do
      [
        category: category_fixture(user),
        category_belonging_to_a_different_user: category_fixture(user_fixture())
      ]
    end

    test "lists all categories belonging to the current user", %{
      conn: conn,
      category: category,
      category_belonging_to_a_different_user: category_belonging_to_a_different_user
    } do
      {:ok, _view, html} = live(conn, ~p"/categories")
      assert html =~ "Categories"
      assert html =~ category.name
      refute html =~ category_belonging_to_a_different_user.name
    end

    test "when there are no categories, shows the intro text", %{
      conn: conn,
      user: user,
      category: category
    } do
      Wmcgy.delete_category(user, category.id)
      {:ok, _view, html} = live(conn, ~p"/categories")
      assert html =~ "Create some categories."

      assert html =~
               "... then navigate back to the transactions page to start tracking your expenses and income."

      assert html =~ "New Category"
    end
  end

  describe "New" do
    setup :register_and_log_in_user
    @category_name "some category name"
    test "saves a new category when supplied a valid name", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/categories")

      assert index_live |> element("a", "New Category") |> render_click() =~
               "New Category"

      assert_patch(index_live, ~p"/categories/new")

      assert index_live
             |> form("#category-form", category: %{name: @category_name})
             |> render_submit()

      assert_patch(index_live, ~p"/categories")
      html = render(index_live)
      assert html =~ "Category created successfully"
      assert html =~ @category_name
    end

    test "displays an error with invalid attributes", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/categories")

      assert index_live |> element("a", "New Category") |> render_click() =~
               "New Category"

      assert_patch(index_live, ~p"/categories/new")

      assert index_live
             |> form("#category-form", category: %{name: ""})
             |> render_submit() =~ "can&#39;t be blank"
    end

    test "displays an error when attempting to create a duplicate category", %{
      conn: conn,
      user: user
    } do
      Wmcgy.create_category(user, @category_name)
      {:ok, index_live, _html} = live(conn, ~p"/categories")

      assert index_live |> element("a", "New Category") |> render_click() =~
               "New Category"

      assert_patch(index_live, ~p"/categories/new")

      assert index_live
             |> form("#category-form", category: %{name: @category_name})
             |> render_submit() =~ "has already been taken"
    end
  end

  describe "Update" do
    setup :register_and_log_in_user

    setup(%{user: user}) do
      [
        category: category_fixture(user)
      ]
    end

    test "updates a category when supplied a valid name", %{conn: conn, category: category} do
      {:ok, index_live, _html} = live(conn, ~p"/categories")

      assert index_live |> element("#categories-#{category.id} a", "Edit") |> render_click() =~
               "Edit Category"

      assert_patch(index_live, ~p"/categories/#{category}/edit")

      assert index_live
             |> form("#category-form", category: %{name: @category_name})
             |> render_submit()

      assert_patch(index_live, ~p"/categories")
      html = render(index_live)
      assert html =~ "Category updated successfully"
      assert html =~ @category_name
    end

    test "displays an error with invalid attributes", %{conn: conn, category: category} do
      {:ok, index_live, _html} = live(conn, ~p"/categories")

      assert index_live |> element("#categories-#{category.id} a", "Edit") |> render_click() =~
               "Edit Category"

      assert_patch(index_live, ~p"/categories/#{category}/edit")

      assert index_live
             |> form("#category-form", category: %{name: nil})
             |> render_submit() =~ "can&#39;t be blank"
    end

    test "displays and error when an update would cause a duplicate", %{
      conn: conn,
      user: user,
      category: category
    } do
      another_category = category_fixture(user)
      {:ok, index_live, _html} = live(conn, ~p"/categories")

      assert index_live |> element("#categories-#{category.id} a", "Edit") |> render_click() =~
               "Edit"

      assert_patch(index_live, ~p"/categories/#{category}/edit")

      assert index_live
             |> form("#category-form", category: %{name: another_category.name})
             |> render_submit() =~ "has already been taken"
    end
  end

  describe "Delete" do
    setup :register_and_log_in_user

    setup(%{user: user}) do
      [
        category: category_fixture(user)
      ]
    end

    test "deletes category in listing", %{conn: conn, category: category} do
      {:ok, index_live, _html} = live(conn, ~p"/categories")
      assert index_live |> element("#categories-#{category.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#categories-#{category.id}")
    end
  end
end
