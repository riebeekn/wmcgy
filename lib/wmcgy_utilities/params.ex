defmodule WmcgyUtilities.Params do
  @moduledoc """
  User input / params handing behaviour
  """
  @callback keys :: list(:atom)

  @callback normalize_parameters(params :: map(), action :: :new | :update) ::
              {:ok, map()} | {:error, Ecto.Changeset.t()}
end

defmodule WmcgyUtilities.Params.Category do
  @moduledoc """
  Category parameter helper module
  """
  alias Ecto.Changeset

  @behaviour WmcgyUtilities.Params

  @category_params %{
    name: :string
  }

  @impl true
  def keys, do: Map.keys(@category_params)

  @impl true
  def normalize_parameters(params, action) do
    {%{}, @category_params}
    |> Changeset.cast(params, keys())
    |> Changeset.validate_required(keys())
    |> Changeset.validate_length(:name, min: 3, max: 100)
    |> Changeset.apply_action(action)
  end
end

defmodule WmcgyUtilities.Params.Transaction do
  @moduledoc """
  Transaction parameter helper module
  """
  alias Ecto.Changeset

  @behaviour WmcgyUtilities.Params

  @transaction_params %{
    amount: :decimal,
    category_id: :integer,
    date: :date,
    description: :string,
    type: :string
  }

  @impl true
  def keys, do: Map.keys(@transaction_params)

  @impl true
  def normalize_parameters(params, action) do
    {%{}, @transaction_params}
    |> Changeset.cast(params, keys())
    |> Changeset.validate_required(keys())
    |> Changeset.validate_length(:description, max: 255)
    |> maybe_round_amount()
    |> atomize_type()
    |> Changeset.apply_action(action)
  end

  defp maybe_round_amount(%Changeset{valid?: true} = changeset) do
    changeset
    |> Changeset.put_change(:amount, Changeset.get_field(changeset, :amount) |> Decimal.round(2))
  end

  defp maybe_round_amount(changeset), do: changeset

  defp atomize_type(changeset) do
    changeset
    |> Changeset.get_field(:type)
    |> case do
      "income" -> Changeset.put_change(changeset, :type, :income)
      "expense" -> Changeset.put_change(changeset, :type, :expense)
      _ -> Changeset.put_change(changeset, :type, nil)
    end
  end
end
