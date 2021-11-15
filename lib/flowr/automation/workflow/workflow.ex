defmodule Flowr.Automation.Workflow do
  use Broadway

  alias Broadway.Message
  alias Flowr.Automation
  alias Flowr.Automation.Workflow.Producer
  alias Flowr.Automation.Workflow.Acknowledger

  def start_link(_opts) do
    Broadway.start_link(__MODULE__,
      name: __MODULE__,
      producer: [
        module: {Producer, []},
        transformer: {__MODULE__, :transform, []}
      ],
      processors: [
        run_task: [concurrency: 2]
      ],
      batchers: []
    )
  end

  @impl true
  def handle_message(:run_task, message, _context) do
    message
    |> Message.update_data(&Automation.run_task/1)
  end

  def transform(task, _opts) do
    %Broadway.Message{
      data: task,
      acknowledger: Acknowledger.build_acknowledger(task.id, task)
    }
  end
end
