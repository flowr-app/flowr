defmodule Flowr.Automation.Workflow.Producer do
  use GenStage

  alias Flowr.Automation.Workflow.TaskFetcher

  # interval in ms
  @default_receive_interval 10_000

  @impl GenStage
  def init(opts) do
    receive_interval = opts[:receive_interval] || @default_receive_interval

    {:producer,
     %{
       demand: 0,
       receive_timer: nil,
       receive_interval: receive_interval
     }}
  end

  @impl GenStage
  def handle_demand(incoming_demand, %{demand: demand} = state) do
    handle_receive_messages(%{state | demand: demand + incoming_demand})
  end

  @impl GenStage
  def handle_info(:fetch_more, state) do
    handle_receive_messages(%{state | receive_timer: nil})
  end

  @impl GenStage
  def handle_info(_, state) do
    {:noreply, [], state}
  end

  defp handle_receive_messages(%{receive_timer: nil, demand: demand} = state)
       when demand > 0 do
    tasks = TaskFetcher.fetch(demand)
    new_demand = demand - length(tasks)

    receive_timer =
      case {tasks, new_demand} do
        {[], _} -> schedule_fetch_more(state.receive_interval)
        {_, 0} -> nil
        _ -> schedule_fetch_more(state.receive_interval)
      end

    {:noreply, tasks, %{state | demand: new_demand, receive_timer: receive_timer}}
  end

  defp handle_receive_messages(state) do
    {:noreply, [], state}
  end

  defp schedule_fetch_more(interval) do
    Process.send_after(self(), :fetch_more, interval)
  end
end
