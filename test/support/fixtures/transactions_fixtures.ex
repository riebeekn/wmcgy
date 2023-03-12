defmodule WmcgyTest.TransactionsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the Categories context.
  """
  use Boundary, check: [in: false, out: false]

  alias Wmcgy.Repo
  alias WmcgySchema.Transaction

  def transaction_fixture(user, category, attrs \\ %{}) do
    attrs = valid_transaction_attributes(user, category, attrs)

    Repo.insert!(attrs)
  end

  defp valid_transaction_attributes(user, category, attrs) do
    params =
      Enum.into(attrs, %{
        description: Faker.Lorem.sentence(2),
        date: Faker.DateTime.backward(30),
        amount: "-#{Faker.Commerce.price()}"
      })
      |> Map.put(:user_id, user.id)
      |> Map.put(:category_id, category.id)
      |> maybe_convert_amount_to_decimal()
      |> set_type

    Ecto.Changeset.cast(%Transaction{}, params, [
      :user_id,
      :category_id,
      :description,
      :date,
      :amount,
      :type
    ])
  end

  defp maybe_convert_amount_to_decimal(%{amount: amount} = attrs)
       when is_integer(amount) or is_binary(amount),
       do: Map.put(attrs, :amount, Decimal.new(amount))

  defp maybe_convert_amount_to_decimal(attrs), do: attrs

  defp set_type(%{amount: amount} = attrs) do
    if Decimal.negative?(amount) do
      Map.put(attrs, :type, :expense)
    else
      Map.put(attrs, :type, :income)
    end
  end
end
