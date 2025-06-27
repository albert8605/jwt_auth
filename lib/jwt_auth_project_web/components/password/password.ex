defmodule JwtAuthProjectWeb.Components.Password do
  @moduledoc false
  use Surface.LiveComponent

  data type, :string, default: "password"
  prop label, :string
  prop value, :string
  prop is_error, :boolean, default: false
  prop values, :keyword, default: []
  prop opts, :keyword, default: []

  def handle_event("fieldchange", %{"type" => type}, socket), do: {:noreply, assign(socket, :type, type)}

end
