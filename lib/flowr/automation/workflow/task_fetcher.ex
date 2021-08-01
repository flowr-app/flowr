defmodule Flowr.Automation.Workflow.TaskFetcher do
  import Ecto.Query

  alias Flowr.Repo
  alias Flowr.Automation.Task
  alias Flowr.Automation.Workflow.Acknowledger

  def init(_init_arg) do
    {:ok, Broadway.TermStorage.put(:automation_runner_task)}
  end

  def fetch(demand, ack_ref) do
    demand
    |> find_pending_tasks()
    |> wrap_into_broadway_messages(ack_ref)
  end

  def find_pending_tasks(count) do
    query =
      from t in Task,
        where: t.status == "pending",
        limit: ^count

    query
    |> Repo.all()
  end

  defp wrap_into_broadway_messages(tasks, ack_ref) do
    tasks
    |> Enum.map(fn task ->
      %Broadway.Message{
        data: task,
        acknowledger: Acknowledger.build_acknowledger(task.id, ack_ref)
      }
    end)
  end
end
