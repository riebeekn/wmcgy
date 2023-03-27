defmodule WmcgyWeb.UserRegistrationLive do
  use WmcgyWeb, :live_view

  # alias Wmcgy.Accounts
  # alias Wmcgy.Accounts.User

  def render(assigns) do
    ~H"""
    <div class="py-24 px-6 sm:px-6 sm:py-32 lg:px-8">
      <div class="mx-auto max-w-md text-center space-y-8">
        <.logo />
        <h2 class="mt-2 text-center text-3xl font-extrabold text-gray-900">
          Sorry we aren't accepting new registrations right now!
        </h2>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
    # changeset = Accounts.change_user_registration(%User{})
    #
    # socket =
    #   socket
    #   |> assign(trigger_submit: false, check_errors: false)
    #   |> assign_form(changeset)
    #
    # {:ok, socket, temporary_assigns: [form: nil]}
  end

  # def handle_event("save", %{"user" => user_params}, socket) do
  #   case Accounts.register_user(user_params) do
  #     {:ok, user} ->
  #       {:ok, _} =
  #         Accounts.deliver_user_confirmation_instructions(
  #           user,
  #           &url(~p"/users/confirm/#{&1}")
  #         )
  #
  #       changeset = Accounts.change_user_registration(user)
  #       {:noreply, socket |> assign(trigger_submit: true) |> assign_form(changeset)}
  #
  #     {:error, %Ecto.Changeset{} = changeset} ->
  #       {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
  #   end
  # end

  # def handle_event("validate", %{"user" => user_params}, socket) do
  #   changeset = Accounts.change_user_registration(%User{}, user_params)
  #   {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  # end

  # defp assign_form(socket, %Ecto.Changeset{} = changeset) do
  #   form = to_form(changeset, as: "user")
  #
  #   if changeset.valid? do
  #     assign(socket, form: form, check_errors: false)
  #   else
  #     assign(socket, form: form)
  #   end
  # end
end
