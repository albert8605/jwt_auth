defmodule JwtAuthProjectWeb.Live.Login do
  use JwtAuthProjectWeb, :live_view

  alias JwtAuthProject.Utils

  data form, :form, default: %{}
  data fields, :list, default: []


  @impl true
  def mount(_params, _session, socket) do
    # Check if user is already authenticated via JWT token
    socket = case get_jwt_token_from_session(socket) do
      nil ->
        assign(socket, notifications: [], jwt_token: nil, current_user: nil, error: nil)
      token ->
        case JwtAuthProjectWeb.AuthController.verify_token_for_live(token) do
          {:ok, claims} ->
            user = JwtAuthProject.Accounts.get_user_by_username_with_role(claims["sub"])
            assign(socket,
              notifications: [],
              jwt_token: token,
              current_user: user,
              error: nil
            )
          {:error, _reason} ->
            assign(socket, notifications: [], jwt_token: nil, current_user: nil, error: nil)
        end
    end

    {:ok, socket}
  end

  defp get_jwt_token_from_session(_socket) do
    # In a real application, you would get this from the session or cookies
    # For now, we'll return nil to force login
    nil
  end

  @impl true
  def handle_event("change", %{"form" => %{"email" => ""} = params, "_target" => ["form", "email"]}, socket) do
    {:noreply,
      socket
      |> assign(:form, params)
      |> update(:fields, & &1 |> Enum.filter(fn {k,_} -> k != :email end) |> Utils.validate_required("email", ""))
    }
  end
  def handle_event("change", %{"form" => %{"email" => email} = params, "_target" => ["form", "email"]}, socket) do
    {:noreply,
      socket
      |> assign(:form, params)
      |> update(:fields, & &1 |> Enum.filter(fn {k,_} -> k != :email end) |> Utils.validate_email_or_username("email", email))
    }
  end

  def handle_event("change", %{"form" => %{"password" => ""} = params, "_target" => ["form", "password"]}, socket) do
    {:noreply,
      socket
      |> assign(:form, params)
      |> update(:fields, & &1 |> Enum.filter(fn {k,_} -> k != :email end) |> Utils.validate_required("password", ""))
    }
  end
  def handle_event("change", %{"form" => %{"password" => password} = params, "_target" => ["form", "password"]}, socket) do
    {:noreply,
      socket
      |> assign(:form, params)
      |> update(:fields, & &1 |> Enum.filter(fn {k,_} -> k != :email end) |> Utils.validate_password("password", password))
    }
  end

  def handle_event("change", _, socket), do: {:noreply, socket}

  def handle_event("send", %{"form" => %{"email" => email_or_username, "password" => password}} = params, socket) do
    # Check if form is valid
    if is_not_valid_form(params["form"]) do
      {:noreply, assign(socket, error: "Please fix the validation errors above") |> notify_error_login("Please fix the validation errors above")}
    else
      # Attempt to authenticate user
      user = JwtAuthProject.Accounts.get_user_by_email_or_username_and_password(email_or_username, password)

      cond do
        is_nil(user) -> {:noreply, notify_error_login(socket, "Invalid credentials")}

        JwtAuthProject.Accounts.user_blacklisted?(user.id) -> {:noreply, notify_error_login(socket,  "User is blacklisted")}

        is_nil(user.role) -> {:noreply, notify_error_login(socket, "No role assigned")}

        true ->
          # Generate JWT token
          token = JwtAuthProject.JWTAuth.generate_token(%{"sub" => user.username, "role" => user.role.name})

          # Verify token for live view
          case JwtAuthProjectWeb.AuthController.verify_token_for_live(token) do
            {:ok, _claims} ->
              # Store token in session or send to client
              socket = assign(socket, :jwt_token, token)
              socket = assign(socket, :current_user, user)
              socket = store_jwt_token(socket, token)

              {:noreply, notify_success_login(socket, user.username)}

            {:error, reason} -> {:noreply, notify_error_login(socket, "Login failed: #{reason}")}
          end
      end
    end
  end
  def handle_event("send", _, socket), do: {:noreply, socket}

  defp is_not_valid_form(%{"email" => ""}), do: true
  defp is_not_valid_form(%{"password" => ""}), do: true
  defp is_not_valid_form(form), do: ([is_valid_email(form), is_valid_password(form)] |> Enum.flat_map(& &1) |> Enum.empty?()) == false

  defp is_valid_email(%{"email" => email}), do: Utils.validate_email_or_username([], "email", email)
  defp is_valid_email(_), do: [Utils.email_valid("email")]

  defp is_valid_password(%{"password" => password}), do: Utils.validate_password([], "password", password)
  defp is_valid_password(_), do: [Utils.password_valid("password")]

  defp notify_success_login(socket, username), do: assign(socket, :error, nil) |> assign(:notifications, [%{type: "success", message: "Login successful for #{username}", id: System.unique_integer()} | socket.assigns.notifications])

  defp notify_error_login(socket, error_msg) do
    assign(socket, :error, error_msg)
    |> assign(:notifications, [%{type: "error", message: error_msg, id: System.unique_integer()} | socket.assigns.notifications])
  end

  defp store_jwt_token(socket, token) do
    # Store JWT token in a secure cookie
    Phoenix.LiveView.push_event(socket, "set_jwt_cookie", %{
      token: token,
      max_age: 3600, # 1 hour
      http_only: true,
      secure: true # Set to true in production with HTTPS
    })
  end

end
