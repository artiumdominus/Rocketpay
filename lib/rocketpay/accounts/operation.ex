defmodule Rocketpay.Accounts.Operation do
  alias Ecto.Multi
  alias Rocketpay.Account

  def call(%{"id" => id, "value" => value}, operation) do
    operation_name = account_operation_name(operation)

    Multi.new()
    |> Multi.run(operation_name, fn repo, _changes -> get_account(repo, id) end)
    |> Multi.run(operation, fn repo, changes ->
      account = Map.get(changes, operation_name)
      update_balance(repo, account, value, operation)
    end)
  end

  defp get_account(repo, id) do
    case repo.get(Account, id) do
      nil -> {:error, "Account not found!"}
      account -> {:ok, account}
    end
  end

  defp update_balance(repo, account, value, operation) do
    case exec_operation(account, value, operation) do
      {:error, _reason} = error -> error
      value ->
        account
      |> Account.changeset(%{balance: value})
      |> repo.update()
    end
  end

  defp exec_operation(%Account{balance: balance}, value, operation) do
    case Decimal.cast(value) do
      {:ok, value} ->
        case operation do
          :deposit -> Decimal.add(balance, value)
          :withdraw -> Decimal.sub(balance, value)
          _ -> {:error, "Invalid operation!"}
        end
      :error -> {:error, "Invalid deposit value!"}
    end
  end

  defp account_operation_name(operation),
    do: "account_#{Atom.to_string(operation)}" |> String.to_atom()
end
