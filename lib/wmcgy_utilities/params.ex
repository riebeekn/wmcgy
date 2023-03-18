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
  alias WmcgyUtilities.DateHelpers

  @behaviour WmcgyUtilities.Params

  @transaction_params %{
    amount: :decimal,
    category_id: :integer,
    date: :string,
    description: :string,
    type: :string
  }

  @impl true
  def keys, do: Map.keys(@transaction_params)

  @impl true
  def normalize_parameters(params, action) do
    {%{}, @transaction_params}
    |> Changeset.cast(params, keys())
    # date is validated via convert_date so we drop the key here
    |> Changeset.validate_required(keys() |> List.delete(:date))
    |> Changeset.validate_length(:description, max: 255)
    |> maybe_round_amount()
    |> atomize_type()
    |> convert_date()
    |> Changeset.apply_action(action)
  end

  defp convert_date(changeset) do
    changeset
    |> Changeset.get_field(:date)
    |> DateHelpers.parse()
    |> case do
      {:ok, date} -> Changeset.put_change(changeset, :date, date)
      {:error, error_msg} -> Changeset.add_error(changeset, :date, error_msg)
    end
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
