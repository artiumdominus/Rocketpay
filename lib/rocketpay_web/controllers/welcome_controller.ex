defmodule RocketpayWeb.WelcomeController do
  use RocketpayWeb, :controller

  alias Rocketpay.Numbers

  def index(conn, %{"filename" => filename}) do
    case Numbers.sum_from_file(filename) do
      {:ok, %{result: result}} ->
        conn
        |> put_status(:ok)
        |> json(%{message: "Welcome to Rocketpay API. Here is your number #{result}"})
      {:error, reason} ->
        conn
        |> put_status(:bad_request)
        |> json(reason)
    end
  end
end
