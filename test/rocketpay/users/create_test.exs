defmodule Rocketpay.Users.CreateTest do
  use Rocketpay.DataCase, async: true

  alias Rocketpay.{User, Users.Create}

  describe "call/1" do
    test "when all params are valid, returns an user" do
      params = %{
        name: "Rafael",
        password: "123456",
        nickname: "camarada",
        email: "rafael@banana.com",
        age: 27
      }

      {:ok, %User{id: user_id}} = Create.call(params)
      user = Repo.get(User, user_id)

      assert %User{name: "Rafael", age: 27, id: ^user_id} = user
    end

    test "when there are invalid params, returns an user" do
      params = %{
        name: "Rafael",
        password: "12345",
        nickname: "camarada",
        email: "rafael@banana.com",
        age: 15
      }

      {:error, changeset} = Create.call(params)

      expected_response = %{
        age: ["must be greater than or equal to 18"],
        password: ["should be at least 6 character(s)"]
      }

      assert errors_on(changeset) == expected_response
    end
  end
end
