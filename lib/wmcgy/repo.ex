defmodule Wmcgy.Repo do
  use Ecto.Repo,
    otp_app: :wmcgy,
    adapter: Ecto.Adapters.Postgres
end
