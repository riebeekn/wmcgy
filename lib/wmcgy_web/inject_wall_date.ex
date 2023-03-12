defmodule WmcgyWeb.InjectWallDate do
  @moduledoc """
  Used to inject wall date to the socket on mount
  """
  import Phoenix.LiveView
  import Phoenix.Component

  # ===========================================================================
  @doc """
  Called on live view mount
  """
  def on_mount(:assign_local_wall_date, _params, _session, socket) do
    if connected?(socket) do
      {:cont, assign(socket, :today, wall_date(socket))}
    else
      {:cont, assign(socket, :today, nil)}
    end
  end

  # ===========================================================================
  @default_timezone "UTC"
  @spec wall_date(Phoenix.LiveView.Socket.t()) :: Date.t()
  def wall_date(socket) do
    if Application.get_env(:wmcgy, :env) == :test do
      mocked_wall_date()
    else
      timezone = get_connect_params(socket)["timezone"] || @default_timezone

      DateTime.utc_now()
      |> DateTime.shift_zone!(timezone)
      |> DateTime.to_date()
    end
  end

  def mocked_wall_date, do: ~D[2020-08-21]
end
