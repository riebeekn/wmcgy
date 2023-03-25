defmodule Wmcgy.TransactionImport.ImportError do
  @moduledoc """
  Module to represent an import error
  """
  @type t :: %__MODULE__{
          row_number: pos_integer(),
          message: String.t()
        }
  defstruct [:row_number, :message]

  def new(error_changeset, row) do
    %__MODULE__{row_number: row, message: error_changeset |> format()}
  end

  # ===========================================================================
  defp format(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Regex.replace(~r"%{(\w+)}", message, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
    |> Enum.map_join(", ", fn {key, val} ->
      "#{key |> maybe_replace_key() |> Atom.to_string() |> String.capitalize() |> String.replace("_", " ")}: #{val}"
    end)
  end

  defp maybe_replace_key(:external_id), do: :id
  defp maybe_replace_key(:name), do: :category_name
  defp maybe_replace_key(key), do: key
end
