defmodule JwtAuthProjectWeb.Components.TextInput do
  @moduledoc false
  use Surface.Component

  prop label, :string
  prop value, :string
  prop is_error, :boolean, default: false
  prop values, :keyword, default: []
  prop opts, :keyword, default: []
end
