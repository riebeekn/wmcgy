defmodule WmcgyUtilities.DateHelpersTest do
  use ExUnit.Case

  alias WmcgyUtilities.DateHelpers

  describe "to_string!/1" do
    test "succeeds on valid dates" do
      assert DateHelpers.to_string(~D[2021-11-04]) == "Nov 04, 2021"
    end

    test "returns an empty string on nil" do
      assert DateHelpers.to_string(nil) == ""
    end
  end
end
