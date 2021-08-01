defmodule Flowr.Platform.Polling.Endpoint do
  def list do
    [
      "/account/~/business-address",
      "/account/~/extension/~/address-book/contact",
      "/account/~/extension/~/phone-number",
      "/account/~/phone-number",
      "/account/~/directory/entries",
      "/account/~/extension/~/call-log",
      "/account/~/extension/~/meeting"
    ]
  end
end
