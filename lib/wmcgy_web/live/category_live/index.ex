defmodule WmcgyWeb.CategoryLive.Index do
  @moduledoc """
  Category Index LV
  """
  use WmcgyWeb, :live_view

  alias WmcgySchema.Category

  # ===========================================================================
  @impl true
  def mount(_params, _session, %{assigns: %{current_user: current_user}} = socket) do
    {:ok, assign_categories(socket, current_user)}
  end

  # ===========================================================================
  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  # ===========================================================================
  @impl true
  def handle_event("delete", %{"id" => id}, %{assigns: %{current_user: current_user}} = socket) do
    current_user
    |> Wmcgy.delete_category(id)

    {:noreply, assign_categories(socket, current_user)}
  end

  # ===========================================================================
  @impl true
  def handle_info(
        {WmcgyWeb.CategoryLive.FormComponent, :saved},
        %{assigns: %{current_user: current_user}} = socket
      ) do
    {:noreply, assign_categories(socket, current_user)}
  end

  # ===========================================================================
  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Category")
    |> assign(:category, %Category{})
  end

  defp apply_action(%{assigns: %{current_user: current_user}} = socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Category")
    |> assign(:category, Wmcgy.get_category!(current_user, id))
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Categories")
    |> assign(:category, nil)
  end

  # ===========================================================================
  defp assign_categories(socket, current_user) do
    assign(socket, :categories, Wmcgy.list_categories(current_user))
  end
end
