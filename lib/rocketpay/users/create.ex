defmodule Rocketpay.Users.Create do
  alias Ecto.Multi
  alias Rocketpay.{Repo, User, Account}

  def call(params) do
    Multi.new()
    |> Multi.insert(:create_user, User.changeset(params))
    |> Multi.run(:create_account, fn repo, %{create_user: user} ->
      account_changeset(user.id) |> repo.insert()
    end)
    |> Multi.run(:preload_data, fn repo, %{create_user: user} ->
      {:ok, repo.preload(user, :account)}
    end)
    |> run_transaction()
  end

  defp account_changeset(user_id), do:
    Account.changeset(%{user_id: user_id, balance: "0.00"})

  defp run_transaction(multi) do
    case Repo.transaction(multi) do
      {:error, _operation, reason, _changes} -> {:error, reason}
      {:ok, %{preload_data: user}} -> {:ok, user}
    end
  end
end
