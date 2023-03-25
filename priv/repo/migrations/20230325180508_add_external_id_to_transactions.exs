defmodule Wmcgy.Repo.Migrations.AddExternalIdToTransactions do
  use Ecto.Migration

  def change do
    alter table(:transactions) do
      add :external_id, :string
    end

    create index(:transactions, [:external_id])
  end
end
