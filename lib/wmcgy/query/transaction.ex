defmodule Wmcgy.Query.Transaction do
  @moduledoc """
  Module to encapsulate any transaction queries
  """
  import Ecto.Query
  alias WmcgySchema.Transaction

  # ===========================================================================
  def for_user(query \\ base(), user) do
    query
    |> where([t], t.user_id == ^user.id)
  end

  # ===========================================================================
  def expense(query) do
    from t in query, where: t.type == :expense
  end

  # ===========================================================================
  def income(query) do
    from t in query, where: t.type == :income
  end

  # ===========================================================================
  def from_date(query, nil), do: query

  def from_date(query, from_date) do
    from t in query, where: t.date >= ^from_date
  end

  # ===========================================================================
  def to_date(query, nil), do: query

  def to_date(query, to_date) do
    from t in query, where: t.date <= ^to_date
  end

  # ===========================================================================
  def include_category(query) do
    query
    |> join(:inner, [t], c in assoc(t, :category))
    |> preload([t, c], category: c)
  end

  # ===========================================================================
  def sum_by_category(query) do
    from t in query,
      inner_join: c in assoc(t, :category),
      group_by: c.name,
      select: %{category: c.name, amount: sum(t.amount)}
  end

  # ===========================================================================
  def sum_by_month_and_year(query) do
    from t in query,
      group_by: [1, 2],
      select: %{
        year: fragment("extract(year from date)::int as year"),
        month: fragment("extract(month from date)::int as month"),
        amount: sum(t.amount)
      }
  end

  # ===========================================================================
  def sum_by_year(query) do
    from t in query,
      group_by: 1,
      order_by: [asc: 1],
      select: %{year: fragment("extract(year from date)::int as period"), amount: sum(t.amount)}
  end

  # ===========================================================================
  def sort_by(query, :category, sort_dir) do
    query
    |> order_by([t, c], [{^sort_dir, c.name}, {^sort_dir, t.id}])
  end

  def sort_by(query, sort_field, sort_dir) do
    query
    |> order_by([t], [{^sort_dir, ^sort_field}, {^sort_dir, t.id}])
  end

  # ===========================================================================
  defp base, do: Transaction
end
