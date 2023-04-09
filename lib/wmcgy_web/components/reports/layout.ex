defmodule WmcgyWeb.Components.Reports.Layout do
  @moduledoc """
  Layout components for the reports page
  """
  use Phoenix.Component

  # ===========================================================================
  attr :title, :string, required: true
  slot :inner_block, required: true

  def report_section_container(assigns) do
    ~H"""
    <div class="mt-4 p-4 bg-emerald-600 rounded-lg overflow-hidden shadow">
      <h3 class="text-white text-2xl font-bold px-2 pb-2"><%= @title %></h3>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  # ===========================================================================
  def report_filter_container(assigns) do
    ~H"""
    <div class="px-2 pt-1 pb-2 ml-4 flex items-baseline">
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  # ===========================================================================
  def report_details_container(assigns) do
    ~H"""
    <div class="grid lg:grid-cols-2 mt-4">
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  # ===========================================================================
  def report_details_left_column_container(assigns) do
    ~H"""
    <div class="lg:mr-2 bg-white">
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  # ===========================================================================
  def report_details_right_column_container(assigns) do
    ~H"""
    <div class="lg:ml-2 lg:mt-0 mt-6 bg-white">
      <%= render_slot(@inner_block) %>
    </div>
    """
  end
end
