defmodule Flowr.Platform.Subscription.EventType do
  def list do
    [
      "/restapi/v1.0/account/~/extension/~/fax?direction=Inbound",
      "/restapi/v1.0/account/~/extension/~/voicemail",
      "/restapi/v1.0/account/~/extension/~/message-store?direction=Inbound",
      "/restapi/v1.0/account/~/extension/~/message-store/instant?type=SMS",
      "/restapi/v1.0/account/~/extension/~/incoming-call-pickup",
      "/restapi/v1.0/account/~/extension/~/missed-calls",
      "/restapi/v1.0/account/~/presence"
    ]
  end
end
