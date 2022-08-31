defmodule Flowr.Automation.Trigger do
  def create_tasks(%Flowr.Platform.Polling.Item{} = polling_item) do
    polling_item =
      polling_item
      |> Flowr.Repo.preload(polling: :trigger)

    polling_item
    |> find_flows()
    |> Flow.from_enumerable()
    |> Flow.map(
      &create_task(&1, %{
        input_data: polling_item.data,
        customer_id: polling_item.polling.trigger.customer_id
      })
    )
    |> Flow.run()
  end

  def create_tasks(%Flowr.Platform.Subscription.Log{} = subscription_log) do
    subscription_log =
      subscription_log
      |> Flowr.Repo.preload(subscription: :trigger)

    subscription_log
    |> find_flows()
    |> Flow.from_enumerable()
    |> Flow.map(
      &create_task(&1, %{
        input_data: subscription_log.info,
        customer_id: subscription_log.subscription.trigger.customer_id
      })
    )
    |> Flow.run()
  end

  def create_tasks(%Flowr.Platform.Webhook.Log{} = webhook_log) do
    webhook_log =
      webhook_log
      |> Flowr.Repo.preload(webhook: :trigger)

    webhook_log
    |> find_flows()
    |> Flow.from_enumerable()
    |> Flow.map(
      &create_task(&1, %{
        input_data: webhook_log.payload,
        customer_id: webhook_log.webhook.trigger.customer_id
      })
    )
    |> Flow.run()
  end

  defp find_flows(%Flowr.Platform.Polling.Item{} = polling_item) do
    polling_item.polling.trigger
    |> Flowr.Automation.list_flows()
  end

  defp find_flows(%Flowr.Platform.Subscription.Log{} = subscription_log) do
    subscription_log.subscription.trigger
    |> Flowr.Automation.list_flows()
  end

  defp find_flows(%Flowr.Platform.Webhook.Log{} = webhook_log) do
    webhook_log.webhook.trigger
    |> Flowr.Automation.list_flows()
  end

  defp create_task(flow, attrs) do
    flow
    |> Ecto.build_assoc(:tasks)
    |> Flowr.Automation.Task.creation_changeset(attrs)
    |> Flowr.Repo.insert()
  end
end
