defmodule Flowr.Automation.Workflow.Acknowledger do
  @behaviour Broadway.Acknowledger

  alias Flowr.Automation

  def build_acknowledger(task, ack_ref) do
    {__MODULE__, ack_ref, task}
  end

  @impl true
  def ack(_ack_ref, successful, failed) do
    # Write ack code here
    successful
    |> Enum.map(&fetch_task/1)
    |> Enum.each(fn task -> Automation.finish_task(task, "success", %{result: "TODO"}) end)

    failed
    |> Enum.map(&fetch_task/1)
    |> Enum.each(fn task -> Automation.finish_task(task, "failed", %{result: "TODO"}) end)
  end

  defp fetch_task(%Broadway.Message{acknowledger: {__MODULE__, _ack_ref, task_id}}) do
    Flowr.Automation.get_task!(task_id)
  end
end
