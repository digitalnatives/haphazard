defmodule HaphazardTest do
  use ExUnit.Case
  use Plug.Test

  doctest Haphazard.Cache

  defmodule TestPlug do
    use Plug.Builder

    plug Haphazard.Cache,
      methods: ~w(POST),
      path: ~r/^\/myroute/,
      ttl: 3000

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
    assert !conn.halted
    conn =
    :post
      |> conn("/myroute", "some_body")
      |> call()
    assert conn.halted
  end

  test "test not matching route, matching verb" do
    conn =
    :post
      |> conn("/notmyroute", "some_body")
      |> call()
    assert !conn.halted
    conn =
    :post
      |> conn("/notmyroute", "some_body")
      |> call()
    assert !conn.halted
  end

  test "test matching route, not matching verb" do
    conn =
    :get
      |> conn("/myroute", "some_body")
      |> call()
    assert !conn.halted
    conn =
    :get
      |> conn("/myroute", "some_body")
      |> call()
    assert !conn.halted
  end

  test "test not matching route, not matching verb" do
    conn =
    :get
      |> conn("/notmyroute", "some_body")
      |> call()
    assert !conn.halted
    conn =
    :get
      |> conn("/notmyroute", "some_body")
      |> call()
    assert !conn.halted
  end

  test "test cache expiration" do
    conn =
    :post
      |> conn("/myroute", "another_body")
      |> call()
    assert !conn.halted
    conn =
    :post
      |> conn("/myroute", "another_body")
      |> call()
    assert conn.halted
    :timer.sleep(3000)
    conn =
    :post
      |> conn("/myroute", "another_body")
      |> call()
    assert !conn.halted
  end

  defmodule TestDisabledPlug do
    use Plug.Builder

    plug Haphazard.Cache,
      enabled: false,
      ttl: 3000

    plug :endroute

    defp endroute(conn, _), do:
      Plug.Conn.send_resp(conn, 200, "ok")
  end

  test "test disabled plug" do
    conn =
    :get
      |> conn("/myroute")
      |> TestDisabledPlug.call(%{})
    assert !conn.halted
    conn =
    :get
      |> conn("/myroute")
      |> TestDisabledPlug.call(%{})
    assert !conn.halted
  end

  defmodule TestCustomTTL do
    use Plug.Builder

    plug Haphazard.Cache,
      ttl: 3000,
      custom: {__MODULE__, :testfunc}

    plug :endroute

    def testfunc(_conn) do
      {:save, 6000}
    end

    defp endroute(conn, _), do:
      Plug.Conn.send_resp(conn, 200, "ok")
  end

  test "test custom ttl" do
    conn =
    :get
      |> conn("/okroute", "another_body")
      |> TestCustomTTL.call(%{})
    assert !conn.halted
    :timer.sleep(3000)
    conn =
    :get
      |> conn("/okroute", "another_body")
      |> TestCustomTTL.call(%{})
    assert conn.halted
    :timer.sleep(3000)
    conn =
    :get
      |> conn("/okroute", "another_body")
      |> TestCustomTTL.call(%{})
    assert !conn.halted
  end
end
