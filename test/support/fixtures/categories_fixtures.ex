defmodule WmcgyTest.CategoriesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Wmcgy.Categories` context.
  """
  use Boundary, check: [in: false, out: false]

  alias Wmcgy.Repo
  alias WmcgySchema.Category

  defp valid_category_name, do: Faker.Lorem.sentence(2)

  def category_fixture(user, name \\ valid_category_name()) do
    %Category{
      name: name,
      user_id: user.id
    }
    |> Repo.insert!()
  end
end
