defmodule Wmcgy.Reports.CategoryReport do
  @moduledoc """
  Module to represent a report grouped by category
  """
  defmodule LineItem do
    @moduledoc """
    A category line item
    """
    @type t :: %__MODULE__{
            category_name: String.t(),
            amount: Decimal.t(),
            percentage: Decimal.t()
          }
    defstruct [:category_name, :amount, :percentage]

    @spec new(
            category_total :: %{category: String.t(), amount: Decimal.t()},
            total_for_all_categories :: Decimal.t()
          ) :: __MODULE__.t()
    def new(%{category: category, amount: amount} = _category_total, total_for_all_categories) do
      percentage =
        amount
        |> Decimal.div(total_for_all_categories)
        |> Decimal.mult(100)
        |> Decimal.round(1)
        |> Decimal.abs()

      %__MODULE__{
        category_name: category,
        amount: amount |> Decimal.abs(),
        percentage: percentage
      }
    end
  end

  @type t :: %__MODULE__{
          start_date: Date.t(),
          end_date: Date.t(),
          type: :expense | :income,
          total_for_all_categories: Decimal.t(),
          line_items: list(__MODULE__.LineItem.t())
        }

  defstruct [:start_date, :end_date, :type, :line_items, :total_for_all_categories]

  @spec new(
          totals_grouped_by_categories :: list(%{category: String.t(), amount: Decimal.t()}),
          start_date :: Date.t(),
          end_date :: Date.t(),
          type :: :expense | :income
        ) :: __MODULE__.t()
  def new(totals_grouped_by_categories, start_date, end_date, type) do
    total_for_all_categories =
      totals_grouped_by_categories
      |> Enum.reduce(Decimal.new(0), fn %{category: _, amount: amount}, acc ->
        Decimal.add(acc, amount)
      end)

    %__MODULE__{
      start_date: start_date,
      end_date: end_date,
      type: type,
      total_for_all_categories: total_for_all_categories |> Decimal.round(2) |> Decimal.abs(),
      line_items:
        totals_grouped_by_categories
        |> Enum.map(&LineItem.new(&1, total_for_all_categories))
        |> Enum.sort_by(& &1.category_name)
    }
  end
end
