defmodule JwtAuthProjectWeb.Components.Notifications do
  use Surface.Component

  prop notifications, :list, default: []

  def notification_class(:info), do: "bg-blue-50 text-blue-900 border border-blue-200"
  def notification_class("info"), do: "bg-blue-50 text-blue-900 border border-blue-200"
  def notification_class(:success), do: "bg-green-50 text-green-900 border border-green-200"
  def notification_class("success"), do: "bg-green-50 text-green-900 border border-green-200"
  def notification_class(:error), do: "bg-red-50 text-red-900 border border-red-200"
  def notification_class("error"), do: "bg-red-50 text-red-900 border border-red-200"
  def notification_class(:warning), do: "bg-yellow-50 text-yellow-900 border border-yellow-200"
  def notification_class("warning"), do: "bg-yellow-50 text-yellow-900 border border-yellow-200"
  def notification_class(_), do: "bg-gray-100 text-gray-900 border border-gray-200"
end
