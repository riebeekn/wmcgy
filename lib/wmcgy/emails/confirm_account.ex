defmodule Wmcgy.Emails.ConfirmAccount do
  @moduledoc """
  Email that gets sent on account creation
  """
  use Wmcgy.Mailer

  def new_email(user, url) do
    new()
    |> to(user.email)
    |> from({"Where Did My Cash Go Yo", "info@wheredidmycashgoyo.com"})
    |> subject("Confirmation instructions")
    |> body(mjml(%{user: user, url: url}))
  end

  defp mjml(assigns) do
    ~H"""
    <.header>
      Welcome to Where Did My Cash Go Yo!
    </.header>
    <.text>
      Thank you for signing up for our service! We're excited to have you onboard!
    </.text>
    <.text>
      To complete your registration, please confirm your email address by clicking the button below:
    </.text>
    <.button url={@url}>Confirm Account</.button>
    <.text>
      If you didn't create an account with us, please ignore this.
    </.text>
    """
  end

  def preview do
    new_email(%{email: "bob@example.com"}, "https://example.com/confirm_account_link")
  end

  def preview_details do
    [
      title: "Confirm Account",
      description: "Sent when the user registers",
      tags: [category: "Accounts"]
    ]
  end
end
