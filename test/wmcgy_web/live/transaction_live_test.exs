defmodule WmcgyWeb.TransactionLiveTest do
  use WmcgyWebTest.ConnCase
  import Phoenix.LiveViewTest

  describe "when not logged in" do
    test "redirects to log in when attempting to access page", %{conn: conn} do
      assert {:error, {:redirect, redirect_map}} = live(conn, ~p"/")
      assert redirect_map.to == ~p"/users/log_in"
    end
  end

  describe "Index" do
    setup :register_and_log_in_user

    test "renders the page", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/")
      assert html =~ "Transactions"
    end
  end
end
