defmodule Wmcgy.Categories do
  @moduledoc """
  Context module for category specific functionality
  """
  alias Ecto.Changeset
  alias Wmcgy.Accounts.User
  alias Wmcgy.Query
  alias Wmcgy.Repo
  alias WmcgySchema.Category

  # ===========================================================================
  def list_categories(%User{} = user) do
    user
    |> Query.Categories.for_user()
    |> Query.Categories.order_by_name()
    |> Repo.all()
  end

  # ===========================================================================
  def get_category!(%User{} = user, id) do
    user
    |> Query.Categories.for_user()
    |> Repo.get!(id)
  end

  # ===========================================================================
  def create_category(%User{} = user, name) do
    %Category{}
    |> Changeset.change(%{name: name, user_id: user.id})
    |> Changeset.unique_constraint(:name, name: :category_user_unique)
    |> Repo.insert()
  end

  # ===========================================================================
  def update_category(%Category{} = category, name) do
    category
    |> Changeset.change(%{name: name})
    |> Changeset.unique_constraint(:name, name: :category_user_unique)
    |> Repo.update()
  end

  # ===========================================================================
  def delete_category(%User{} = user, id) do
    user
    |> Query.Categories.for_user()
    |> Repo.get!(id)
    |> Changeset.change(%{})
    |> Changeset.foreign_key_constraint(:transactions,
      name: :transactions_category_id_fkey,
      message: "category in use"
    )
    |> Repo.delete()
  end

  # ===========================================================================
  def has_categories?(%User{} = user) do
    user
    |> Query.Categories.for_user()
    |> Repo.aggregate(:count) > 0
  end
end
