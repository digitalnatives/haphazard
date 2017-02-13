defmodule HaphazardTest do
  use ExUnit.Case
  use Plug.Test

  doctest Haphazard.Cache

  defmodule TestPlug do
    use Plug.Builder

    plug Haphazard.Cache,
      methods: ~w(POST),
      path: ~r/^\/myroute/

    plug :endroute

    defp endroute(conn, _), do:
      Plug.Conn.send_resp(conn, 200, "ok")
  end

  defp call(conn), do: TestPlug.call(conn, %{})

  test "test matching route, matching verb" do
    conn =
    :post
      |> conn("/myroute", "some_body")
      |> call()
    assert conn.status == 200
    conn =
    :post
      |> conn("/myroute", "some_body")
      |> call()
    assert conn.status == 304
  end

end
