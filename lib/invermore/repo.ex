defmodule Invermore.Repo do
  use Ecto.Repo,
    otp_app: :invermore,
    adapter: Ecto.Adapters.Postgres
end
