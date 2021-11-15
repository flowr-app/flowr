defmodule Flowr.Automation.Workflow.TaskFetcher do
  import Ecto.Query

  alias Flowr.Repo
  alias Flowr.Automation.Task

  def fetch(demand) do
    demand
    |> find_pending_tasks()
  end

  def find_pending_tasks(count) do
    query =
      from t in Task,
        where: t.status == "pending",
        limit: ^count

    query
    |> Repo.all()
  end

  # defp wrap_into_broadway_messages(tasks) do
  #   tasks
  #   |> Enum.map(fn task ->
  #     %Broadway.Message{
  #       data: task,
  #       acknowledger: Acknowledger.build_acknowledger(task.id, ack_ref)
  #     }
  #   end)
  # end
end
