defmodule WmcgySchema.Category do
  @moduledoc """
  Category schema
  """
  use Ecto.Schema

  alias Wmcgy.Accounts.User

  @type t :: %__MODULE__{
          name: String.t(),
          user_id: pos_integer(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "categories" do
    field :name, :string
    belongs_to :user, User
    timestamps()
  end
end
