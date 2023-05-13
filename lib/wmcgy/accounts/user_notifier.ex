defmodule Wmcgy.Accounts.UserNotifier do
  alias Wmcgy.Emails
  alias Wmcgy.Mailer

  # Delivers the email using the application mailer.
  defp deliver(email) do
    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end

  @doc """
  Deliver instructions to confirm account.
  """
  def deliver_confirmation_instructions(user, url) do
    user
    |> Emails.ConfirmAccount.new_email(url)
    |> deliver()
  end

  @doc """
  Deliver instructions to reset a user password.
  """
  def deliver_reset_password_instructions(user, url) do
    user
    |> Emails.ResetPassword.new_email(url)
    |> deliver()
  end

  @doc """
  Deliver instructions to update a user email.
  """
  def deliver_update_email_instructions(user, url) do
    user
    |> Emails.UpdateEmailAddress.new_email(url)
    |> deliver()
  end
end
