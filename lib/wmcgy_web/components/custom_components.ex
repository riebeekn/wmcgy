defmodule WmcgyWeb.CustomComponents do
  @moduledoc """
  Provides custom UI components.
  """

  use Phoenix.Component

  # ===========================================================================
  @doc """
  Renders the logo.
  ## Examples
    <.logo />
  """
  def logo(assigns) do
    ~H"""
    <div class="text-center text-emerald-500 ml-2 font-semi-bold text-5xl font-lobster">Wmcgy</div>
    """
  end

  # ===========================================================================
  @doc """
  Renders a styled page header.
  ## Examples
    <.page_header_title>Transactions</.page_title_title>
  """
  def page_header_title(assigns) do
    ~H"""
    <h1 class="text-3xl font-extrabold text-zinc-900">
      <%= render_slot(@inner_block) %>
    </h1>
    """
  end
end
