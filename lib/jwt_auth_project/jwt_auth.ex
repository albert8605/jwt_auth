defmodule JwtAuthProject.JWTAuth do
  @moduledoc """
  Provides functions for encoding, decoding, and verifying JWT tokens.
  """

  @algo "HS256"
  @secret "super_secret_key" # In production, use ENV vars
  @blacklist ["banned_user", "evil_admin"]

  def generate_token(payload) when is_map(payload) do
    payload = Map.put_new(payload, "exp", exp_time())
    key = :jose_jwk.from_oct(@secret)
    JOSE.JWT.sign(key, payload)
    |> JOSE.JWS.compact()
    |> elem(1)
  end

  def verify_token(token) do
    key = :jose_jwk.from_oct(@secret)
    case JOSE.JWT.verify_strict(key, [@algo], token) do
      {true, %JOSE.JWT{fields: claims}, _jws} ->
        cond do
          Map.get(claims, "sub") in @blacklist ->
            {:error, :blacklisted_user}
          is_nil(Map.get(claims, "role")) ->
            {:error, :no_role_assigned}
          is_token_expired?(claims) ->
            {:error, :token_expired}
          true ->
            {:ok, claims}
        end
      _ ->
        {:error, :invalid_token}
    end
  end

  defp exp_time do
    DateTime.utc_now() |> DateTime.add(3600, :second) |> DateTime.to_unix()
  end

  defp is_token_expired?(claims) do
    case Map.get(claims, "exp") do
      nil -> false
      exp when is_integer(exp) ->
        current_time = DateTime.utc_now() |> DateTime.to_unix()
        exp < current_time
      _ -> false
    end
  end
end
