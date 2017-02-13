defmodule Haphazard.Cache do
  @moduledoc false
  import Plug.Conn
  alias Haphazard.Server

  def init(opts) do
    methods = Keyword.fetch!(opts, :methods)
    path = Keyword.fetch!(opts, :path)
    {methods, path}
  end

  def call(conn, {methods, path}) do
    if conn.method in methods
      and Regex.match?(path, conn.request_path)
    do
      check_cache(conn)
    else
      conn
    end
  end

  defp check_cache(conn) do
    case conn |> hash_key() |> Server.lookup_request() do
      {:cached, resp_body} ->
        conn
          |> put_resp_content_type("text/xml")
          |> send_resp(304, resp_body)
          |> halt
      :not_cached ->
        conn
          |> register_before_send(&save_cache(&1))
          |> save_req_body()
    end
  end

  defp hash_key(conn) do
    {:ok, body, conn} = read_body(conn)
    hash = :crypto.hash(:md5, conn.request_path <> body)
    hash |> Base.encode16
  end

  defp save_cache(conn) do
    conn
      |> hash_key2()
      |> Server.store_cache(conn.resp_body)
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
