defmodule Wmcgy.Emails.UpdateEmailAddressTest do
  use ExUnit.Case

  alias Wmcgy.Accounts.User
  alias Wmcgy.Emails.UpdateEmailAddress

  describe "new_email/2" do
    setup do
      %{user: %User{email: "bob@example.com"}, url: "https://example.com/confirm_email_change"}
    end

    test "to, from and subject are as expected and body contains the confirm url", %{
      user: user,
      url: url
    } do
      email = UpdateEmailAddress.new_email(user, url)

      assert email.to == [{"", user.email}]
      assert email.from == {"Where Did My Cash Go Yo", "info@wheredidmycashgoyo.com"}
      assert email.subject == "Update email instructions"
      assert email.html_body =~ url
      assert email.text_body =~ url
    end
  end
end
