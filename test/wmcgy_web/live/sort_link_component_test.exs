defmodule WmcgyWeb.SortLinkComponentTest do
  use WmcgyWebTest.ConnCase

  import Phoenix.LiveViewTest

  alias WmcgyWeb.SortLinkComponent

  describe "render/1" do
    test "sets the label and sort field value" do
      html =
        render_component(SortLinkComponent,
          id: "transactions-date-sort-link",
          label: "Date",
          sort_field: :date,
          current_sort_field: :date,
          current_sort_dir: :asc
        )

      assert html |> strip_html() =~ "Date"
      assert html =~ "phx-value-sort_field=\"date\""
    end

    test "when current sort field renders a direction icon" do
      html =
        render_component(SortLinkComponent,
          id: "transactions-date-sort-link",
          label: "Date",
          sort_field: :date,
          current_sort_field: :date,
          current_sort_dir: :asc
        )

      assert html =~ "hero-arrow-up"

      html =
        render_component(SortLinkComponent,
          id: "transactions-date-sort-link",
          label: "Date",
          sort_field: :date,
          current_sort_field: :date,
          current_sort_dir: :desc
        )

      assert html =~ "hero-arrow-down"
    end

    test "when not the current sort field does not render direction icon" do
      html =
        render_component(SortLinkComponent,
          id: "transactions-date-sort-link",
          label: "Date",
          sort_field: :date,
          current_sort_field: :amount,
          current_sort_dir: :asc
        )

      refute html =~ "hero-arrow-up"

      html =
        render_component(SortLinkComponent,
          id: "transactions-date-sort-link",
          label: "Date",
          sort_field: :date,
          current_sort_field: :amount,
          current_sort_dir: :desc
        )

      refute html =~ "hero-arrow-down"
    end
  end

  describe "parse_sort_field_param/3" do
    test "returns default with invalid params" do
      assert :date == SortLinkComponent.parse_sort_field_param(%{}, :date, ["date", "amount"])

      assert :date ==
               SortLinkComponent.parse_sort_field_param(
                 %{"sort_field" => "not_a_sort_field"},
                 :date,
                 ["date", "amount"]
               )
    end

    test "returns expected atom with valid params" do
      assert :date ==
               SortLinkComponent.parse_sort_field_param(%{"sort_field" => "date"}, :date, [
                 "date",
                 "amount"
               ])

      assert :amount ==
               SortLinkComponent.parse_sort_field_param(%{"sort_field" => "amount"}, :date, [
                 "date",
                 "amount"
               ])
    end
  end

  describe "parse_sort_dir_param/1" do
    test "defaults to descending with invalid params" do
      assert :desc == SortLinkComponent.parse_sort_dir_param(%{})
      assert :desc == SortLinkComponent.parse_sort_dir_param(%{"sort_dir" => "not_a_sort_dir"})
    end

    test "returns expected atom with valid params" do
      assert :asc == SortLinkComponent.parse_sort_dir_param(%{"sort_dir" => "asc"})
      assert :desc == SortLinkComponent.parse_sort_dir_param(%{"sort_dir" => "desc"})
    end
  end
end
