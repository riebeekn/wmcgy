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

  describe "parse/1" do
    test "succeeds on valid date strings" do
      assert {:ok, ~D[2021-11-04]} == DateHelpers.parse("Nov 04, 2021")
    end

    test "returns can't be blank on empty date string" do
      assert {:error, "can't be blank"} == DateHelpers.parse("")
      assert {:error, "can't be blank"} == DateHelpers.parse("  ")
    end

    test "returns invalid on invalid string" do
      assert {:error, "is invalid"} == DateHelpers.parse("Feb 31, 2000")
      assert {:error, "is invalid"} == DateHelpers.parse("Bob")
    end

    test "return invalid on non string" do
      assert {:error, "is invalid"} == DateHelpers.parse(~D[2021-11-04])
      assert {:error, "is invalid"} == DateHelpers.parse(1)
    end
  end
end
