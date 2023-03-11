# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Wmcgy.Repo.insert!(%Wmcgy.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

# register a user that we will attach some transactions and data to
{:ok, bob} = Wmcgy.Accounts.register_user(%{email: "bob@example.com", password: "foobarfoobar"})

# register another user with no transactions
{:ok, _sally} = Wmcgy.Accounts.register_user(%{email: "sally@example.com", password: "foobarfoobar"})

# create some categories
{:ok, clo} = Wmcgy.create_category(bob, "Cloths")
{:ok, ent} = Wmcgy.create_category(bob, "Entertainment")
{:ok, groc} = Wmcgy.create_category(bob, "Groceries")
{:ok, oieo} = Wmcgy.create_category(bob, "Ordering in / eating out")
{:ok, pay} = Wmcgy.create_category(bob, "Pay")
{:ok, rent} = Wmcgy.create_category(bob, "Rent")
{:ok, transpo} = Wmcgy.create_category(bob, "Transportation")
{:ok, utils} = Wmcgy.create_category(bob, "Utilities")

# generate a bunch of transactions
today = Date.utc_today()
# generate transactions for the last 6 odd years
years = (today.year..Date.add(today, -365*5).year) |> Enum.to_list()

# generate some somewhat realistic income transactions, assuming get paid once a month
# on the 15th and that pay amount is static
for year <- years, month <- 12..1 do
  transaction_date = Date.new!(year, month, 15)

  # don't create transactions that are in the future
  unless transaction_date.year == today.year &&
           transaction_date.month >= today.month,
         do:
           Wmcgy.create_transaction(bob, %{
             category_id: pay.id,
             description: "Pay",
             date: transaction_date,
             amount: Decimal.new("8000") |> Decimal.round(2),
             type: :income
           })
end

# generate some somewhat realistic rent transactions
for year <- years, month <- 12..1 do
  transaction_date = Date.new!(year, month, 1)

  # don't create transactions that are in the future
  unless transaction_date.year == today.year &&
           transaction_date.month >= today.month,
         do:

           Wmcgy.create_transaction(bob, %{
             category_id: rent.id,
             description: "Rent",
             date: transaction_date,
             amount: Decimal.new("2500") |> Decimal.round(2),
             type: :expense
           })
end

# generate a bunch of random expenses
for year <- years, _transactions_per_year <- 1..400 do
  transaction_date = Date.new!(year, Enum.random(1..12), Enum.random(1..28))

  category = Enum.random([clo, ent, groc, oieo, transpo, utils])

  unless (transaction_date.year == today.year &&
            transaction_date.month > today.month) ||
           (transaction_date.year == today.year &&
              transaction_date.month == today.month &&
              transaction_date.day > today.day),
         do:
           Wmcgy.create_transaction(bob, %{
             category_id: category.id,
             description: Faker.Lorem.sentence(1..3),
             date: transaction_date,
             amount: Faker.random_between(5, 400) |> Decimal.new() |> Decimal.round(2),
             type: :expense
           })
end
