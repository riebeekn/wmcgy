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
  def include_category(query) do
    query
    |> join(:inner, [t], c in assoc(t, :category))
    |> preload([t, c], category: c)
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
