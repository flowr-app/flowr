defmodule Flowr.Automation.Workflow do
  use Broadway

  alias Broadway.Message
  alias Flowr.Automation
  alias Flowr.Automation.Workflow.Producer

  def start_link(_opts) do
    Broadway.start_link(__MODULE__,
      name: __MODULE__,
      producer: [
        module: {Producer, []}
      ],
      processors: [
        run_task: [concurrency: 2]
      ]
    )
  end

  @impl true
  def handle_message(:run_task, message, _context) do
    message
    |> Message.update_data(&Automation.run_task/1)
  end
end
