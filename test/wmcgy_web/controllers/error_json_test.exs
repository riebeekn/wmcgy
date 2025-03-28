defmodule WmcgyWeb.ErrorJSONTest do
  use WmcgyWebTest.ConnCase, async: true

  test "renders 404" do
    assert WmcgyWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert WmcgyWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
