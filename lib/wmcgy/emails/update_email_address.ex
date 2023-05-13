defmodule Wmcgy.Emails.UpdateEmailAddress do
  @moduledoc """
  Email that gets sent to confirm and email address change
  """
  use Wmcgy.Mailer

  def new_email(user, url) do
    new()
    |> to(user.email)
    |> from({"Where Did My Cash Go Yo", "info@wheredidmycashgoyo.com"})
    |> subject("Update email instructions")
    |> body(mjml(%{user: user, url: url}))
  end

  defp mjml(assigns) do
    ~H"""
    <.header>
      Change your email
    </.header>
    <.text>
      A request has been received to change the email for your account.
    </.text>
    <.text>
      To confirm this change click the button below:
    </.text>
    <.button url={@url}>Change Email</.button>
    <.text>
      If you didn't request this change, please ignore this.
    </.text>
    """
  end

  # coveralls-ignore-start
  def preview do
    new_email(%{email: "bob@example.com"}, "https://example.com/confirm_account_link")
  end

  def preview_details do
    [
      title: "Update Email Address",
      description: "Sent when the user up",
      tags: [category: "Accounts"]
    ]
  end

  # coveralls-ignore-stop
end
