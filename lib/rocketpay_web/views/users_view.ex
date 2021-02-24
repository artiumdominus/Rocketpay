defmodule RocketpayWeb.UsersView do

  def render("create.json", %{user: user}) do
    %{
      message: "User created",
      user: %{
        id: user.id,
        name: user.name,
        nickname: user.nickname
      }
    }
  end
end
