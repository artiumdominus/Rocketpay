defmodule RocketpayWeb.UsersControllerTest do
  use RocketpayWeb.ConnCase, async: true

  describe "create/2" do
    test "when all params are valid, create the user", %{conn: conn} do
      params = %{
        name: "Pedro",
        password: "654321",
        nickname: "artiumdominus",
        email: "basilio@goiaba.com",
        age: 25
      }

      response =
        conn
        |> post(Routes.users_path(conn, :create, params))
        |> json_response(:created)

      assert %{
        "message" => "User created",
        "user" => %{
          "account" => %{
            "balance" => "0.00",
            "id" => _account_id
          },
          "id" => _id,
          "name" => "Pedro",
          "nickname" => "artiumdominus"
        }
      } = response
    end

    test "when there are invalid params, return errors", %{conn: conn} do
      params = %{
        name: "Pedro",
        password: "65432",
        nickname: "artiumdominus",
        age: 17
      }

      response =
        conn
        |> post(Routes.users_path(conn, :create, params))
        |> json_response(:bad_request)

      expected_response = %{
        "message" => %{
          "age" => ["must be greater than or equal to 18"],
          "email" => ["can't be blank"],
          "password" => ["should be at least 6 character(s)"]
        }
      }

      assert response == expected_response
    end
  end
end
