defmodule WmcgyWeb.PagerComponentTest do
  use WmcgyWebTest.ConnCase

  import Phoenix.LiveViewTest

  alias WmcgyWeb.PagerComponent

  describe "render/1 - status message" do
    test "displays the status" do
      html =
        render_component(PagerComponent,
          id: "page-component",
          current_page: 2,
          current_page_size: 10,
          total_pages: 10,
          total_entries: 100
        )

      assert html |> strip_html() =~ "Showing 11 to 20 of 100 results"
    end

    test "handles invalid page values" do
      # page of 0
      html =
        render_component(PagerComponent,
          id: "page-component",
          current_page: 1,
          current_page_size: 10,
          total_pages: 10,
          total_entries: 100
        )

      assert html |> strip_html() =~ "Showing 1 to 10 of 100 results"

      # page that exceeds the total number of pages
      html =
        render_component(PagerComponent,
          id: "page-component",
          current_page: 11,
          current_page_size: 10,
          total_pages: 10,
          total_entries: 100
        )

      assert html |> strip_html() =~ "Showing 91 to 100 of 100 results"

      html =
        render_component(PagerComponent,
          id: "page-component",
          current_page: 3,
          current_page_size: 10,
          total_pages: 2,
          total_entries: 11
        )

      assert html |> strip_html() =~ "Showing 11 to 11 of 11 results"
    end
  end

  describe "parse_page_param" do
    test "returns 1 with invalid params" do
      assert 1 == PagerComponent.parse_page_param(%{})
      assert 1 == PagerComponent.parse_page_param(%{"page" => "not_an_integer"})
      assert 1 == PagerComponent.parse_page_param(%{"page" => "0"})
      assert 1 == PagerComponent.parse_page_param(%{"page" => "-1"})
    end

    test "returns expected value with valid params" do
      assert 2 == PagerComponent.parse_page_param(%{"page" => "2"})
    end
  end

  describe "parse_page_size_param" do
    test "returns 30 with invalid params" do
      assert 30 == PagerComponent.parse_page_size_param(%{})
      assert 30 == PagerComponent.parse_page_size_param(%{"page_size" => "not_an_integer"})
    end
  end
end
