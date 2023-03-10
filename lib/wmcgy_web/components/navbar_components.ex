defmodule WmcgyWeb.NavbarComponents do
  @moduledoc """
  Navbar related components
  """
  use Phoenix.Component

  use Phoenix.VerifiedRoutes,
    endpoint: WmcgyWeb.Endpoint,
    router: WmcgyWeb.Router,
    statics: WmcgyWeb.static_paths()

  alias Phoenix.LiveView.JS

  def navbar(assigns) do
    ~H"""
    <nav class="bg-white shadow">
      <.main_menu current_user={@current_user} />
      <.mobile_menu current_user={@current_user} />
    </nav>
    """
  end

  # ===========================================================================
  attr :current_user, :any, required: true

  defp main_menu(assigns) do
    ~H"""
    <div class="mx-auto max-w-7xl px-2 sm:px-6 lg:px-8">
      <div class="relative flex h-16 items-center justify-between">
        <.mobile_menu_button />
        <.main_menu_links />
        <.user_settings_drop_down_menu current_user={@current_user} />
      </div>
    </div>
    """
  end

  # ===========================================================================
  attr :current_user, :any, required: true

  defp mobile_menu(assigns) do
    ~H"""
    <div class="hidden sm:hidden" id="mobile-menu">
      <div class="space-y-1 px-2 pt-2 pb-3">
        <.mobile_menu_link link_text="Transactions" href={~p"/"} />
        <.mobile_menu_link link_text="Categories" href={~p"/categories"} />
        <.mobile_menu_link link_text="Reports" href="#" />
      </div>
      <div class="pt-4 pb-3 border-t border-gray-700">
        <div class="px-2">
          <div class="text-sm font-medium text-gray-500"><%= @current_user.email %></div>
        </div>
        <div class="mt-3 px-2 space-y-1">
          <.mobile_menu_link link_text="Account" href={~p"/users/settings"} />
          <.mobile_menu_link link_text="Sign out" href={~p"/users/log_out"} method="delete" />
        </div>
      </div>
    </div>
    """
  end

  # ===========================================================================
  attr :current_user, :any, required: true

  defp user_settings_drop_down_menu(assigns) do
    ~H"""
    <div class="absolute inset-y-0 right-0 items-center pr-2 sm:static sm:inset-auto sm:ml-6 sm:pr-0 hidden md:block">
      <div class="relative ml-3">
        <.user_settings_drop_down_button current_user={@current_user} />
        <.user_settings_drop_down_menu_items />
      </div>
    </div>
    """
  end

  # ===========================================================================
  defp user_settings_drop_down_menu_items(assigns) do
    ~H"""
    <!-- Dropdown menu, show/hide based on menu state. -->
    <div
      id="profile-menu"
      class="hidden absolute right-0 z-10 mt-2 w-48 origin-top-right rounded-md bg-white shadow-lg ring-1 ring-black ring-opacity-5 focus:outline-none"
      role="menu"
      aria-orientation="vertical"
      aria-labelledby="user-menu-button"
      tabindex="-1"
    >
      <.user_settings_drop_down_link
        id="user-menu-item-0"
        link_text="Account"
        href={~p"/users/settings"}
      />
      <.user_settings_drop_down_link
        id="user-menu-item-1"
        link_text="Sign out"
        href={~p"/users/log_out"}
        method="delete"
      />
    </div>
    """
  end

  # ===========================================================================
  attr :current_user, :any, required: true

  defp user_settings_drop_down_button(assigns) do
    ~H"""
    <div>
      <button
        type="button"
        class="flex text-sm"
        id="user-menu-button"
        aria-expanded="false"
        aria-haspopup="true"
        phx-click-away={hide_profile_menu()}
        phx-click={toggle_profile_menu()}
      >
        <span class="sr-only">Open user menu</span>
        <%= @current_user.email %>
        <WmcgyWeb.CoreComponents.icon name="hero-chevron-down" class="block h-5 w-5 stroke-current" />
      </button>
    </div>
    """
  end

  # ===========================================================================
  attr :id, :string, required: true
  attr :link_text, :string, required: true
  attr :href, :string, required: true
  attr :rest, :global, include: ~w(method)

  defp user_settings_drop_down_link(assigns) do
    ~H"""
    <.link
      id={@id}
      href={@href}
      role="menuitem"
      tabindex="-1"
      class="hover:bg-gray-100 block px-4 py-2 text-sm text-gray-700"
      {@rest}
    >
      <%= @link_text %>
    </.link>
    """
  end

  # ===========================================================================
  attr :link_text, :string, required: true
  attr :href, :string, required: true
  attr :rest, :global, include: ~w(method)

  defp mobile_menu_link(assigns) do
    ~H"""
    <.link
      href={@href}
      class="text-gray-800 hover:bg-emerald-600 hover:text-white block px-3 py-2 rounded-md text-base font-medium"
      {@rest}
    >
      <%= @link_text %>
    </.link>
    """
  end

  # ===========================================================================
  defp main_menu_links(assigns) do
    ~H"""
    <div class="flex flex-1 items-center justify-center sm:items-stretch sm:justify-start">
      <.logo />
      <div class="hidden sm:ml-6 sm:block">
        <div class="flex space-x-4">
          <.main_menu_link link_text="Transactions" href={~p"/"} />
          <.main_menu_link link_text="Categories" href={~p"/categories"} />
          <.main_menu_link link_text="Reports" href="#" />
        </div>
      </div>
    </div>
    """
  end

  # ===========================================================================
  attr :link_text, :string, required: true
  attr :href, :string, required: true

  defp main_menu_link(assigns) do
    ~H"""
    <a
      href={@href}
      class="text-zinc-900 px-3 py-2 rounded-md text-sm font-medium hover:bg-emerald-500 hover:text-white"
    >
      <%= @link_text %>
    </a>
    """
  end

  # ===========================================================================
  defp logo(assigns) do
    ~H"""
    <div class="flex flex-shrink-0 items-center">
      <a href="/" class="mr-2 text-emerald-500 font-semi-bold text-3xl font-lobster">Wmcgy</a>
    </div>
    """
  end

  # ===========================================================================
  defp mobile_menu_button(assigns) do
    ~H"""
    <div class="absolute inset-y-0 left-0 flex items-center sm:hidden">
      <!-- Mobile menu button-->
      <button
        phx-click-away={hide_mobile_menu()}
        phx-click={toggle_mobile_menu()}
        type="button"
        class="inline-flex items-center justify-center rounded-md p-2 text-gray-400 hover:bg-gray-700 hover:text-white focus:outline-none focus:ring-2 focus:ring-inset focus:ring-white"
        aria-controls="mobile-menu"
        aria-expanded="false"
      >
        <span class="sr-only">Open main menu</span>
        <!--
                Icon when menu is open.
              -->
        <span id="mobile_menu_is_open_icon" class="hidden">
          <WmcgyWeb.CoreComponents.icon name="hero-x-mark" class="h-6 w-6 stroke-current" />
        </span>
        <!--
                Icon when menu is closed.
              -->
        <span id="mobile_menu_is_closed_icon" class="block">
          <WmcgyWeb.CoreComponents.icon name="hero-bars-3-solid" class="h-6 w-6 stroke-current" />
        </span>
      </button>
    </div>
    """
  end

  defp toggle_mobile_menu(js \\ %JS{}) do
    js
    |> JS.toggle(to: "#mobile-menu", in: "ease-out duration-100", out: "ease-in duration-75")
    |> JS.toggle(to: ["#mobile_menu_is_closed_icon", "#mobile_menu_is_open_icon"])
  end

  defp hide_mobile_menu(js \\ %JS{}) do
    js
    |> JS.hide(to: "#mobile-menu", transition: "ease-in duration-75")
    |> JS.hide(to: "#mobile_menu_is_open_icon")
    |> JS.show(to: "#mobile_menu_is_closed_icon")
  end

  defp toggle_profile_menu(js \\ %JS{}) do
    js
    |> JS.toggle(
      to: "#profile-menu",
      in:
        {"ease-out duration-100", "transform opacity-0 scale-95",
         "transform opacity-100 scale-100"},
      out:
        {"ease-in duration-75", "transform opacity-100 scale-100", "transform opacity-0 scale-95"}
    )
  end

  defp hide_profile_menu(js \\ %JS{}) do
    js
    |> JS.hide(
      to: "#profile-menu",
      transition:
        {"ease-in duration-75", "transform opacity-100 scale-100", "transform opacity-0 scale-95"}
    )
  end
end
