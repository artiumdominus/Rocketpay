defmodule Rocketpay.Accounts.Deposit do
  alias Ecto.Multi
  alias Rocketpay.{Repo, Account}

  def call(%{"id" => id, "value" => value}) do
      Multi.new()
      |> Multi.run(:account, fn repo, _changes -> get_account(repo, id) end)
      |> Multi.run(:update_balance, fn repo, %{account: account} ->
        update_balance(repo, account, value)
      end)
      |> run_transaction()
  end

  defp get_account(repo, id) do
    case repo.get(Account, id) do
      nil -> {:error, "Account not found!"}
      account -> {:ok, account}
    end
  end

  defp update_balance(repo, account, value) do
    case sum_values(account, value) do
      {:error, _reason} = error -> error
      value ->
        account
      |> Account.changeset(%{balance: value})
      |> repo.update()
    end
  end

  defp sum_values(%Account{balance: balance}, value) do
    case Decimal.cast(value) do
      {:ok, value} -> Decimal.add(value, balance)
      :error -> {:error, "Invalid deposit value!"}
    end
  end

  defp run_transaction(multi) do
    case Repo.transaction(multi) do
      {:error, _operation, reason, _changes} -> {:error, reason}
      {:ok, %{update_balance: account}} -> {:ok, account}
    end
  end
end
