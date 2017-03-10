defmodule HaphazardTest.Server do
  use ExUnit.Case
  use Plug.Test

  doctest Haphazard.Server
  alias Haphazard.Server

  test "cleanup cache" do
    Server.store_cache("key", "body", 10000)
    Server.lookup_request("key")
    Server.cleanup
    assert Server.lookup_request("key") == :not_cached
  end

end
