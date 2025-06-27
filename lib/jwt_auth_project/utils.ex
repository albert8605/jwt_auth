defmodule JwtAuthProject.Utils do
  import Plug.Conn, only: [put_resp_cookie: 4, resp: 3, put_resp_header: 3, halt: 1]

  @email_regex ~r/^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/u
  @password_regex ~r/^[A-Za-z0-9_]{8,}$/
  @username_regex ~r/^[A-Za-z0-9_]+$/


  def part_url(url, :domain), do: ~r/^(\w+[\-]?)(\w+[\-]?[\w])|(\.)|[^.]+$/ |> Regex.replace(url |> URI.parse() |> Map.get(:host, ""), "")
  def part_url(url, :appname), do: ~r/(\..+)|(\w+[^chi]\-+)/ |> Regex.replace(url |> URI.parse() |> Map.get(:host, ""), "")

  def send_params(params, conn), do:
    conn
    |> put_resp_cookie("ticket", params.ticket, [http_only: false, max_age: 7 * 24 * 60 * 60, domain: domain(conn)])
    |> put_resp_cookie("username", params.username, [http_only: false, max_age: 7 * 24 * 60 * 60, domain: domain(conn)])
    # |> put_resp_cookie("redirect", "", [http_only: false, max_age: -1, domain: domain(conn)])
    |> put_resp_header("location", params.redirect)
    # |> put_resp_header("location", params |> host_domain())
    |> resp(:found, "")
    |> halt()

  def host_domain(%{ticket: t, redirect: r}, path \\ "auth") do
    uri = r |> URI.parse()
    "#{uri.scheme}://#{uri.host}/#{path}?redirect=#{r}&ticket=#{t}"
  end


  def set_cookie_ticket(params, key, socket) do
    socket
      |> Phoenix.LiveView.push_event(
        key,
        %{
          params: [
            %{key: "ticket", value: params.ticket},
            %{key: "username", value: params.username}
          ],
          ticket: params.ticket,
          rememberme: params.rememberme |> boolean_checkbox(),
          host: params.host
        }
      )
  end

  def map_from_url(url) do
    query = url |> URI.parse() |> Map.get(:query)
    params =
      case query do
        nil -> %{}
        query ->
          query
          |> String.split("&")
          |> Enum.reduce(%{}, fn pair, acc ->
            [key, value] = String.split(pair, "=", parts: 2)
            Map.put(acc, String.to_atom(key), value)
          end)
      end
    params
    |> Map.merge(url |> URI.parse() |> Map.take([:host, :path]))
  end

  def hostname(conn), do: Enum.into(conn.req_headers, %{}) |> Map.get("host")
  def domain(conn), do: Regex.run(~r/\.\w+[\-]?\w+\.\w+$/, hostname(conn))
  def max_age() do
    DateTime.add(DateTime.utc_now(), 7 * 24 * 60 * 60, :second)
    # |> DateTime.to_string()
  end


  # Convert checkbox value to boolean
  def boolean_checkbox(str), do: str == "on"

  def validate_required(fields, field, value) when value in [nil, ""], do: [required_valid(field) | fields] |> Enum.uniq()
  def validate_required([], field, _), do: [required_valid(field)] |> Enum.uniq()
  def validate_required(fields, field, _), do: fields -- [required_valid(field)]

  def validate_password(fields, field, value) do
    case Regex.match?(@password_regex, value) do
      false -> [password_valid_complex(field) | fields] |> Enum.uniq()
      _ -> fields -- [password_valid_complex(field)]
    end
  end

  def validate_email(fields, field, value) do
    case Regex.match?(@email_regex, value) do
      false -> [email_valid(field) | fields] |> Enum.uniq()
      _ -> fields -- [email_valid(field)]
    end
  end

  def validate_password_confirm(fields, field1, field2, value1, value2) do
    case value1 == value2 do
      false -> [password_confirm_valid(field1) | [password_confirm_valid(field2) | fields]] |> Enum.uniq()
      _ -> fields -- [password_confirm_valid(field1), password_confirm_valid(field2)]
    end
  end

  def validate_username(fields, field, value) do
    case Regex.match?(@username_regex, value) do
      false -> [username_valid_format(field) | fields] |> Enum.uniq()
      _ -> fields -- [username_valid_format(field)]
    end
  end

  def validate_email_or_username(fields, field, value) do
    cond do
      Regex.match?(@email_regex, value) || Regex.match?(@username_regex, value) -> fields -- [email_or_username_valid(field)]

      true -> [email_or_username_valid(field) | fields] |> Enum.uniq()
    end
  end

  def filter_errors(errors) do
    errors
    |> Enum.reverse()
    |> Enum.reduce(%{}, fn {field, message}, acc ->
      Map.update(acc, field, message, &(&1))
    end)
    |> Map.to_list()
  end

  def field_error(errors, field) when is_binary(field), do: String.to_atom(field) in Keyword.keys(errors)
  def field_error(errors, field), do: field in Keyword.keys(errors)
  def email_valid(field), do: to_valid(field, "The e-mail format is not valid.")
  def password_confirm_valid(field), do: to_valid(field, "Passwords must match.")
  def required_valid(field), do: to_valid(field, "This field is required.")
  def username_valid(field), do: to_valid(field, "The user does not exist.")
  def password_valid(field), do: to_valid(field, "Invalid password.")
  def password_valid_complex(field), do: to_valid(field, "The password must contain letters, numbers, a capital letter or special character, and be at least 8 characters long.")
  def username_valid_format(field), do: to_valid(field, "The username must contain only letters and numbers.")
  def email_or_username_valid(field), do: to_valid(field, "Must be a valid email or username (letters and numbers only).")
  def to_valid(field, error), do: {String.to_atom(field), error}

  def inspect_block(to_inspect, msg \\"-------------------------------") do
    IO.inspect(msg)
    IO.inspect(to_inspect, structs: false)
    IO.inspect(msg)
    to_inspect
  end

  def map_keys_atom_to_string(map) when is_struct(map), do: Map.from_struct(map) |> map_keys_atom_to_string()
  def map_keys_atom_to_string(map), do: (for {key, val} <- map, into: %{}, do: {Atom.to_string(key), val})

  def map_keys_string_to_atom(map) when is_struct(map), do: Map.from_struct(map) |> map_keys_string_to_atom()
  def map_keys_string_to_atom(map), do: (for {key, val} <- map, into: %{}, do: {String.to_atom(key), val})

end
