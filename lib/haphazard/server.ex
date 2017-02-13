defmodule Haphazard.Server do
  @moduledoc """
  Simple cache server that triggers a periodic cleanup with every insertion
  """
  use GenServer

  @table_name :request_cache

  @spec start_link(integer) :: {:ok, pid()}
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @spec init(integer) :: {:ok, %{table: integer, timer: integer}}
  def init(timer) do
    :ets.new(@table_name, [:set, :named_table])

    {:ok, %{timer: timer}}
  end

  @spec lookup_request(any()) :: any()
  def lookup_request(key) do
    GenServer.call(__MODULE__, {:lookup, key})
  end

  @spec store_cache(any(), any()) :: :ok
  def store_cache(key, body) do
    GenServer.cast(__MODULE__, {:store, key, body})
  end

  @spec handle_call({:lookup, any()}, pid(), any()) :: {:reply, {:cached, any}, any()} | {:reply, :not_cached, any()}
  def handle_call({:lookup, key}, _from, state) do
    case :ets.lookup(@table_name, key) do
      [{^key, cached}] -> {:reply, {:cached, cached}, state}
      []               -> {:reply, :not_cached      , state}
    end
  end

  @spec handle_cast({:store, any(), any()}, %{timer: integer}) :: {:noreply, any()}
  def handle_cast({:store, key, body}, state = %{timer: timer}) do
    :ets.insert(@table_name, {key, body})
    Process.send_after(self(), {:invalidate, key}, timer)
    {:noreply, state}
  end

  @spec handle_info({:invalidate, any()}, any()) :: {:noreply, any()}
  def handle_info({:invalidate, key}, state) do
    :ets.delete(@table_name, key)
    {:noreply, state}
  end

end
