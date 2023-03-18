defmodule WmcgyUtilities.DateHelpers do
  @moduledoc """
  Various date helpers
  """

  @format "%b %d, %Y"

  # ===========================================================================
  @doc """
  Returns a string representation of a date in mmm dd, yyyy format (i.e. Jan 04, 2021)
  """
  @spec to_string(Date.t()) :: String.t()
  def to_string(%Date{} = date) do
    Calendar.strftime(date, @format)
  end

  def to_string(nil), do: ""

  # ===========================================================================
  @doc """
  Parse a date string in the format of mmm dd, yyyy
  """
  @spec parse(String.t()) :: {:ok, Date.t()} | {:error, msg :: String.t()}
  def parse(nil) do
    {:error, "can't be blank"}
  end

  def parse(date_string) when is_binary(date_string) do
    if String.trim(date_string) == "" do
      {:error, "can't be blank"}
    else
      date_string
      |> Datix.Date.parse(@format)
      |> case do
        {:ok, date} -> {:ok, date}
        {:error, _} -> {:error, "is invalid"}
      end
    end
  end

  def parse(_), do: {:error, "is invalid"}
end
