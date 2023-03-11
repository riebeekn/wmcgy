defmodule WmcgyUtilities.DateHelpers do
  @moduledoc """
  Various date helpers
  """
  @integer_to_month_map %{
    1 => "jan",
    2 => "feb",
    3 => "mar",
    4 => "apr",
    5 => "may",
    6 => "jun",
    7 => "jul",
    8 => "aug",
    9 => "sep",
    10 => "oct",
    11 => "nov",
    12 => "dec"
  }

  # ===========================================================================
  @doc """
  Returns a string representation of a date in mmm dd, yyyy format (i.e. Jan 04, 2021)
  """
  @spec to_string(Date.t()) :: String.t()
  def to_string(%Date{} = date) do
    "#{Map.get(@integer_to_month_map, date.month) |> String.capitalize()} #{date.day |> Integer.to_string() |> String.pad_leading(2, "0")}, #{date.year}"
  end

  def to_string(nil), do: ""
end
