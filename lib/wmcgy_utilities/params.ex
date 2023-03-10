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
