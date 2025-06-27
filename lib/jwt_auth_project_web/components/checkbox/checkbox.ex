defmodule JwtAuthProjectWeb.Components.Checkbox do
  @moduledoc false
  use Surface.Component

  prop label, :string
  prop value, :string
  prop opts, :keyword, default: []
end
