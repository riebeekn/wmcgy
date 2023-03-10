defmodule Wmcgy.Repo.Migrations.CreateCategories do
  use Ecto.Migration

  def change do
    create table(:categories) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :name, :citext, null: false
      timestamps()
    end

    create index(:categories, [:user_id])
    create unique_index(:categories, [:user_id, :name], name: :category_user_unique)
  end
end
