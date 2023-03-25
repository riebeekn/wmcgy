defmodule WmcgySchema.Transaction do
  @moduledoc """
  Transaction schema
  """
  use Ecto.Schema

  @type t :: %__MODULE__{
          external_id: String.t(),
          description: String.t(),
          date: Date.t(),
          amount: Decimal.t(),
          type: :income | :expense,
          user_id: pos_integer(),
          category_id: pos_integer(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "transactions" do
    field :external_id, :string
    field :description, :string
    field :date, :date
    field :amount, :decimal
    field :type, Ecto.Enum, values: [:income, :expense]
    belongs_to :user, Wmcgy.Accounts.User
    belongs_to :category, WmcgySchema.Category

    timestamps()
  end
end
