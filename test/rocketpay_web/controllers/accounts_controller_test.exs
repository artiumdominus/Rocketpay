defmodule RocketpayWeb.AccountsControllerTest do
  use RocketpayWeb.ConnCase, async: true

  alias Rocketpay.{Account, User}

  describe "deposit/2" do
    setup %{conn: conn} do
      params = %{
        name: "Rafael",
        password: "123456",
        nickname: "camarda",
        email: "rafael@banana.com",
        age: 27
      }

      {:ok, %User{account: %Account{id: account_id}}} = Rocketpay.create_user(params)

      conn = put_req_header(conn, "authorization", "Basic YmFuYW5hOm5hbmljYTEyMw==")

      {:ok, conn: conn, account_id: account_id}
    end

    test "when all params are valid, make the deposit", %{conn: conn, account_id: account_id} do
      params = %{"value" => "50.00"}

      response =
        conn
        |> post(Routes.accounts_path(conn, :deposit, account_id, params))
        |> json_response(:ok)

      assert %{
        "account" => %{"balance" => "50.00", "id" => _id},
        "message" => "Ballance changed successfully"
      } = response
    end

    test "when there are invalid params, returns an error", %{conn: conn, account_id: account_id} do
      params = %{"value" => "banana"}

      response =
        conn
        |> post(Routes.accounts_path(conn, :deposit, account_id, params))
        |> json_response(:bad_request)

      expected_response = %{"message" => "Invalid deposit value!"}

      assert response == expected_response
    end
  end

  describe "withdraw/2" do
    setup %{conn: conn} do
      params = %{
        name: "Rafael",
        password: "123456",
        nickname: "camarda",
        email: "rafael@banana.com",
        age: 27
      }

      {:ok, %User{account: %Account{id: account_id}}} = Rocketpay.create_user(params)

      Rocketpay.deposit(%{"id" => account_id, "value" => "100.00"})

      conn = put_req_header(conn, "authorization", "Basic YmFuYW5hOm5hbmljYTEyMw==")

      {:ok, conn: conn, account_id: account_id}
    end

    test "when all params are valid, make the withdraw", %{conn: conn, account_id: account_id} do
      params = %{"value" => "30.00"}

      response =
        conn
        |> post(Routes.accounts_path(conn, :withdraw, account_id, params))
        |> json_response(:ok)

      assert %{
        "account" => %{"balance" => "70.00", "id" => _id},
        "message" => "Ballance changed successfully"
      } = response
    end

    test "when there are invalid params, returns an error", %{conn: conn, account_id: account_id} do
      params = %{"value" => "banana"}

      response =
        conn
        |> post(Routes.accounts_path(conn, :withdraw, account_id, params))
        |> json_response(:bad_request)

      expected_response = %{"message" => "Invalid withdraw value!"}

      assert response == expected_response
    end
  end

  describe "transaction/2" do
    setup %{conn: conn} do
      sender_account_params = %{
        name: "Rafael",
        password: "123456",
        nickname: "camarda",
        email: "rafael@banana.com",
        age: 27
      }

      {:ok, %User{account: %Account{id: sender_account_id}}} = Rocketpay.create_user(sender_account_params)

      Rocketpay.deposit(%{"id" => sender_account_id, "value" => "100.00"})

      receiver_account_params = %{
        name: "Pedro",
        password: "654321",
        nickname: "artiumdominus",
        email: "basilio@goiaba.com",
        age: 25
      }

      {:ok, %User{account: %Account{id: receiver_account_id}}} = Rocketpay.create_user(receiver_account_params)

      Rocketpay.deposit(%{"id" => receiver_account_id, "value" => "100.00"})

      conn = put_req_header(conn, "authorization", "Basic YmFuYW5hOm5hbmljYTEyMw==")

      {:ok, conn: conn, sender_account_id: sender_account_id, receiver_account_id: receiver_account_id}
    end

    test "when all params are valid, make the withdraw", %{conn: conn, sender_account_id: sender_account_id, receiver_account_id: receiver_account_id} do
      params = %{"value" => "70.00", from: sender_account_id, to: receiver_account_id}

      response =
        conn
        |> post(Routes.accounts_path(conn, :transaction, params))
        |> json_response(:ok)

      expected_response = %{
        "message" => "Transaction done successfully",
        "transaction" => %{
          "from_account" => %{
            "balance" => "30.00",
            "id" => sender_account_id
          },
          "to_account" => %{
            "balance" => "170.00",
            "id" => receiver_account_id
          }
        }
      }

      assert response == expected_response
    end

    test "when there are invalid params, returns an error", %{conn: conn, sender_account_id: sender_account_id, receiver_account_id: receiver_account_id} do
      params = %{"value" => "banana", from: sender_account_id, to: receiver_account_id}

      response =
        conn
        |> post(Routes.accounts_path(conn, :transaction, params))
        |> json_response(:bad_request)

      expected_response = %{"message" => "Invalid withdraw value!"}

      assert response == expected_response
    end

    test "when value is negative, returns an error", %{conn: conn, sender_account_id: sender_account_id, receiver_account_id: receiver_account_id} do
      params = %{"value" => "-70.00", from: sender_account_id, to: receiver_account_id}

      response =
        conn
        |> post(Routes.accounts_path(conn, :transaction, params))
        |> json_response(:bad_request)

      expected_response = %{"message" => "Invalid withdraw value! (must be positive)"}

      assert response == expected_response
    end
  end
end
