defmodule Wmcgy.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :category_id, references(:categories, on_delete: :nothing), null: false
      add :description, :string, null: false
      add :date, :date, null: false
      add :amount, :decimal, default: 0.00, null: false
      add :type, :string, null: false
      timestamps()
    end

    create index(:transactions, [:user_id])
  end
end
