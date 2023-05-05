defmodule Wmcgy.Emails.Gallery do
  @moduledoc """
  Swoosh preview gallery items
  """
  use Swoosh.Gallery

  group "/accounts", title: "Accounts" do
    preview("/confirmation", Wmcgy.Emails.ConfirmAccount)
    preview("/reset", Wmcgy.Emails.ResetPassword)
    preview("/update_email", Wmcgy.Emails.UpdateEmailAddress)
  end
end
