defmodule WmcgySchema.Category do
  @moduledoc """
  Category schema
  """
  use Ecto.Schema

  alias Wmcgy.Accounts.User

  schema "categories" do
    field :name, :string
    belongs_to :user, User
    timestamps()
  end
end
