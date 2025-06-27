defmodule JwtAuthProjectWeb.Components.Field do
  use Surface.Component
  alias Surface.Components.Form.{Field, ErrorTag}

  # prop form, :any
  prop label, :string
  prop name, :atom
  prop value, :string
  prop class, :css_class, default: []
  prop align, :string, default: "center"
  prop type, :atom
  prop required, :boolean, default: false
  prop is_error, :boolean, default: false
  prop keydown, :event
  prop values, :keyword, default: []
  prop disabled, :boolean, default: false
  prop readonly, :boolean, default: false
  prop opts, :keyword, default: []
  prop form, :form, from_context: {Form, :form}

  def form_error_class(_, _), do: form_error_class(false)
  def form_error_class(true), do: " border-red-300 focus:outline-none focus:ring-red-500 focus:border-red-500"
  def form_error_class(_), do: ""
end
