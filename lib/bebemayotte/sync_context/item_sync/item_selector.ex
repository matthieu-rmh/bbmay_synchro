defmodule Bebemayotte.ItemSelector do
  alias Bebemayotte.SyncContext
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def init(state) do

    spawn_liners()

    check_from_each_item()

    {:ok, state}
  end

  defp spawn_liners do
    Enum.each(SyncContext.select_item_ids, fn id ->
      start_liner(id)
    end)
  end

  defp check_from_each_item do
    Enum.each(list_item_pids(), fn pid ->
      GenServer.cast(pid, :check)
    end)
  end

  def list_item_pids do
    Enum.map(Supervisor.which_children(Bebemayotte.ItemSupervisor), fn {_,pid,_,_} ->
      pid
     end)
  end

  defp start_liner(id) do
    DynamicSupervisor.start_child(Bebemayotte.ItemSupervisor, %{id: Bebemayotte.ItemLiner, start: {Bebemayotte.ItemLiner, :start_link, [%{id: id}]} })
  end

end