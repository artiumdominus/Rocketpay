defmodule Rocketpay.Numbers do
  def sum_from_file(filename) do
    case File.read("#{filename}.csv") do
      {:ok, file_content} ->
        result = file_content
        |> String.split(",")
        |> Stream.map(&String.to_integer/1)
        |> Enum.sum

        {:ok, %{result: result}}
      {:error, _reason} ->
        {:error, %{message: "Invalid file!"}}
    end
  end
end
