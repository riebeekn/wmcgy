defmodule Wmcgy.Query.Categories do
  @moduledoc """
  Module to encapsulate any category queries
  """
  import Ecto.Query
  alias WmcgySchema.Category

  # ===========================================================================
  def for_user(query \\ base(), user) do
    query
    |> where([c], c.user_id == ^user.id)
  end

  # ===========================================================================
  def by_name(query, name) do
    query
    |> where([c], c.name == ^name)
  end

  # ===========================================================================
  def order_by_name(query) do
    query
    |> order_by([c], c.name)
  end

  # ===========================================================================
  defp base, do: Category
end
