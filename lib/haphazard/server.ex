defmodule Haphazard.Server do
  @moduledoc """
  Simple cache server that triggers a periodic cleanup with every insertion
  """
  use GenServer

  @table_name :request_cache

  @spec start_link :: {:ok, pid()}
  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @spec init(any()) :: {:ok, nil}
  def init(_) do
    :ets.new(@table_name, [:set, :named_table])

    {:ok, []}
  end

  @spec lookup_request(any()) :: any()
  def lookup_request(key) do
    GenServer.call(__MODULE__, {:lookup, key})
  end

  @spec store_cache(any(), any(), integer) :: :ok
  def store_cache(key, body, ttl) do
    GenServer.cast(__MODULE__, {:store, key, body, ttl})
  end

  @spec handle_call({:lookup, any()}, pid(), any()) :: {:reply, {:cached, any}, any()} | {:reply, :not_cached, any()}
  def handle_call({:lookup, key}, _from, state) do
    case :ets.lookup(@table_name, key) do
      [{^key, cached}] -> {:reply, {:cached, cached}, state}
      []               -> {:reply, :not_cached      , state}
    end
  end

  @spec handle_cast({:store, any(), any()}, any()) :: {:noreply, any()}
  def handle_cast({:store, key, body, ttl}, state) do
    :ets.insert(@table_name, {key, body})
    Process.send_after(self(), {:invalidate, key}, ttl)
    {:noreply, state}
  end

  @spec handle_info({:invalidate, any()}, any()) :: {:noreply, any()}
  def handle_info({:invalidate, key}, state) do
    :ets.delete(@table_name, key)
    {:noreply, state}
  end

end
