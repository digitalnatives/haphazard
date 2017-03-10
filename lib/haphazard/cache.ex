defmodule Haphazard.Cache do
  @moduledoc false
  import Plug.Conn
  alias Haphazard.Server

  @type opts :: %{
    methods: [String.t],
    path: Regex.t,
    ttl: integer,
    enabled: boolean,
    custom: {module(), fun()}
  }

  @spec init(Keyword.t) :: opts
  def init(opts) do
    %{
      methods: Keyword.get(opts, :methods, ~w(GET HEAD)),
      path: Keyword.get(opts, :path, ~r/.*/),
      ttl: Keyword.get(opts, :ttl, 15 * 60 * 1000),
      enabled: Keyword.get(opts, :enabled, true),
      custom: Keyword.get(opts, :custom, {__MODULE__, :default})
    }
  end

  @spec call(Plug.Conn.t, opts) :: Plug.Conn.t
  def call(conn, %{enabled: false}), do: conn
  def call(conn, %{methods: methods, path: path} = opts) do
    if conn.method in methods
    and Regex.match?(path, conn.request_path)
    do
      check_cache(conn, opts)
    else
      conn
    end
  end

  @spec default(Plug.Conn.t) :: {:save | :dont_save, integer | :default}
  def default(conn) do
    {:save, :default}
  end

  defp check_cache(conn, opts) do
    case conn |> hash_key() |> Server.lookup_request() do
      {:cached, resp_body} -> send_cached(conn, resp_body)
      :not_cached          -> register_for_caching(conn, opts)
    end
  end

  defp register_for_caching(conn, %{ttl: ttl, custom: {module, function}}) do
    case apply(module, function, [conn]) do
      {:save, :default} -> conn
        |> register_before_send(&save_cache(&1, ttl))
        |> save_req_body()
      {:save, new_ttl}  -> conn
        |> register_before_send(&save_cache(&1, new_ttl))
        |> save_req_body()
      {:dont_save, _}   -> conn
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

  defp send_cached(conn, resp_body) do
    conn
    |> put_resp_content_type("text/xml")
    |> send_resp(200, resp_body)
    |> halt
  end
end
