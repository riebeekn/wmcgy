defmodule WmcgyWeb.CategoryLive.FormComponent do
  @moduledoc """
  Category form LV
  """
  use WmcgyWeb, :live_component

  alias Ecto.Changeset
  alias WmcgyUtilities.Params

  # ===========================================================================
  @impl true
  def update(%{category: category} = assigns, socket) do
    changeset =
      category
      |> Changeset.cast(%{}, Params.Category.keys())

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  # ===========================================================================
  @impl true
  def handle_event("save", %{"category" => category_params}, socket) do
    save_category(socket, socket.assigns.action, category_params)
  end

  # ===========================================================================
  defp save_category(%{assigns: %{current_user: current_user}} = socket, :new, params) do
    params
    |> Params.Category.normalize_parameters(:new)
    |> case do
      {:ok, normalized_params} ->
        case Wmcgy.create_category(current_user, normalized_params.name) do
          {:ok, _category} ->
            notify_parent(:saved)

            {:noreply,
             socket
             |> put_flash(:info, "Category created successfully")
             |> push_patch(to: socket.assigns.patch)}

          {:error, %Ecto.Changeset{} = changeset} ->
            {:noreply, assign_form(socket, changeset)}
        end

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_category(%{assigns: %{category: existing_category}} = socket, :edit, params) do
    params
    |> Params.Category.normalize_parameters(:edit)
    |> case do
      {:ok, normalized_params} ->
        case Wmcgy.update_category(existing_category, normalized_params.name) do
          {:ok, _category} ->
            notify_parent(:saved)

            {:noreply,
             socket
             |> put_flash(:info, "Category updated successfully")
             |> push_patch(to: socket.assigns.patch)}

          {:error, %Ecto.Changeset{} = changeset} ->
            {:noreply, assign_form(socket, changeset)}
        end

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  # ===========================================================================
  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset, as: :category))
  end

  # ===========================================================================
  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
