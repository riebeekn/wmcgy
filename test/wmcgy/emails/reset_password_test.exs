defmodule Wmcgy.Emails.ResetPasswordTest do
  use ExUnit.Case

  alias Wmcgy.Accounts.User
  alias Wmcgy.Emails.ResetPassword

  describe "new_email/2" do
    setup do
      %{user: %User{email: "bob@example.com"}, url: "https://example.com/reset"}
    end

    test "to, from and subject are as expected and body contains the confirm url", %{
      user: user,
      url: url
    } do
      email = ResetPassword.new_email(user, url)

      assert email.to == [{"", user.email}]
      assert email.from == {"Where Did My Cash Go Yo", "info@wheredidmycashgoyo.com"}
      assert email.subject == "Reset password instructions"
      assert email.html_body =~ url
      assert email.text_body =~ url
    end
  end
end
