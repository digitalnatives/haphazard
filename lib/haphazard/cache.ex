defmodule Haphazard.Cache do
  @moduledoc false
  import Plug.Conn
  alias Haphazard.Server

  @spec init(Keyword.t) :: {[String.t], Regex.t, integer, boolean}
  def init(opts) do
    methods = Keyword.get(opts, :methods, ~w(GET HEAD))
    path = Keyword.get(opts, :path, ~r/.*/)
    ttl = Keyword.get(opts, :ttl, 15 * 60 * 1000)
    enabled = Keyword.get(opts, :enabled, true)
    {methods, path, ttl, enabled}
  end

  @spec call(Plug.Conn.t, {[String.t], Regex.t, integer, boolean}) :: Plug.Conn.t
  def call(conn, {methods, path, ttl, enabled}) do
    if conn.method in methods
      and Regex.match?(path, conn.request_path)
      and enabled
    do
      check_cache(conn, ttl)
    else
      conn
    end
  end

  defp check_cache(conn, ttl) do
    case conn |> hash_key() |> Server.lookup_request() do
      {:cached, resp_body} ->
        conn
          |> put_resp_content_type("text/xml")
          |> send_resp(200, resp_body)
          |> halt
      :not_cached ->
        conn
          |> register_before_send(&save_cache(&1, ttl))
          |> save_req_body()
    end
  end

  defp hash_key(conn) do
    {:ok, body, conn} = read_body(conn)
    hash = :crypto.hash(:md5, conn.request_path <> body)
    hash |> Base.encode16
  end

  defp save_cache(conn, ttl) do
    conn
      |> hash_key2()
      |> Server.store_cache(conn.resp_body, ttl)
    conn
  end

  defp hash_key2(conn) do
    key = conn.request_path <> conn.private[:cache_request]
    :md5
      |> :crypto.hash(key)
      |> Base.encode16
  end

  defp save_req_body(conn) do
    {:ok, body, _} = read_body(conn)
    put_private(conn, :cache_request, body)
  end

end
