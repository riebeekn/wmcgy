defmodule WmcgyUtilities do
  @moduledoc """
  Top level utilities module
  """
  use Boundary, deps: [WmcgySchema], exports: [DateHelpers, Params.Category]
end
