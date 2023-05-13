defmodule Wmcgy.Emails.ResetPassword do
  @moduledoc """
  Email that gets sent on reset password request
  """
  use Wmcgy.Mailer

  def new_email(user, url) do
    new()
    |> to(user.email)
    |> from({"Where Did My Cash Go Yo", "info@wheredidmycashgoyo.com"})
    |> subject("Reset password instructions")
    |> body(mjml(%{user: user, url: url}))
  end

  defp mjml(assigns) do
    ~H"""
    <.header>
      Reset your password
    </.header>
    <.text>
      A request has been received to change the password for your account.
    </.text>
    <.text>
      To change your password click the button below:
    </.text>
    <.button url={@url}>Reset Password</.button>
    <.text>
      If you didn't request a password reset, you can ignore this email.  Your password will not be changed.
    </.text>
    """
  end

  # coveralls-ignore-start
  def preview do
    new_email(%{email: "bob@example.com"}, "https://example.com/reset_password_link")
  end

  def preview_details do
    [
      title: "Reset Password",
      description: "Sent when the user requests a password reset",
      tags: [category: "Accounts"]
    ]
  end

  # coveralls-ignore-stop
end
