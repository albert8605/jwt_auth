# JWT Authentication Project

A comprehensive JWT authentication system built with Elixir, Phoenix, and PostgreSQL. This project provides a complete authentication solution with user management, role-based access control, user blacklisting, and both API and LiveView interfaces.

## Features

- **JWT Token Authentication**: Secure token-based authentication with configurable expiration
- **User Management**: Complete user registration, login, and profile management
- **Role-Based Access Control**: Flexible role system with database-backed roles
- **User Blacklisting**: Ability to blacklist users with reason tracking
- **Dual Interface**: Both REST API and LiveView interfaces
- **Real-time Validation**: Client-side and server-side validation
- **Security Features**: Password hashing, CSRF protection, secure cookies
- **Comprehensive Testing**: 100+ test cases covering all functionality
- **Database Integration**: PostgreSQL with Ecto ORM
- **Modern UI**: Tailwind CSS with responsive design

## Table of Contents

- [Installation](#installation)
- [Configuration](#configuration)
- [Database Setup](#database-setup)
- [API Documentation](#api-documentation)
- [LiveView Interface](#liveview-interface)
- [Security Features](#security-features)
- [Testing](#testing)
- [Deployment](#deployment)
- [Project Structure](#project-structure)

## Installation

### Prerequisites

- Elixir 1.18+ and Erlang/OTP 27+
- PostgreSQL 12+
- Node.js 18+ (for asset compilation)

### Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd jwt_auth
   ```

2. **Install dependencies**
   ```bash
   mix deps.get
   npm install --prefix assets
   ```

3. **Configure environment**
   ```bash
   cp config/dev.exs.example config/dev.exs
   # Edit config/dev.exs with your database credentials
   ```

4. **Setup database**
   ```bash
   mix ecto.create
   mix ecto.migrate
   mix run priv/repo/seeds.exs
   ```

5. **Start the server**
   ```bash
   mix phx.server
   ```

The application will be available at `http://localhost:4000`

## Configuration

### Environment Variables

Create a `.env` file in the project root:

```bash
# Database
DATABASE_URL=postgresql://username:password@localhost/jwt_auth_dev

# JWT Secret (change in production!)
JWT_SECRET=your_super_secret_key_here

# Application
SECRET_KEY_BASE=your_secret_key_base_here
```

### Database Configuration

Update `config/dev.exs`:

```elixir
config :jwt_auth_project, JwtAuthProject.Repo,
  username: "your_username",
  password: "your_password",
  hostname: "localhost",
  database: "jwt_auth_dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10
```

## Database Setup

### Migrations

The project includes the following database migrations:

1. **Users Table** (`20250625163741_create_users.exs`)
   - Basic user information (username, email, password_hash)
   - Active status and blacklist flags

2. **Roles Table** (`20250625165209_create_roles.exs`)
   - Role definitions with unique names
   - Timestamps for audit trail

3. **User-Role Relationship** (`20250625165219_add_role_id_to_users.exs`)
   - Foreign key relationship between users and roles

4. **User Blacklists Table** (`20250625171711_create_user_blacklists.exs`)
   - Blacklist tracking with reasons and timestamps

### Seeds

Run the seed file to create initial data:

```bash
mix run priv/repo/seeds.exs
```

This creates:
- Default roles (user, admin)
- Sample users for testing
- Initial blacklist entries

## API Documentation

### Authentication Endpoints

#### POST /api/login

Authenticate a user and receive a JWT token.

**Request Body:**
```json
{
  "username": "user123",
  "password": "password123"
}
```

**Response (Success - 200):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": 1,
    "username": "user123",
    "email": "user@example.com",
    "role": "user"
  }
}
```

**Response (Error - 401):**
```json
{
  "error": "Invalid credentials"
}
```

#### POST /api/verify

Verify a JWT token and get user information.

**Request Body:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Response (Success - 200):**
```json
{
  "valid": true,
  "claims": {
    "sub": "user123",
    "role": "user",
    "exp": 1640995200
  },
  "user": {
    "id": 1,
    "username": "user123",
    "role": "user"
  }
}
```

**Response (Error - 401):**
```json
{
  "valid": false,
  "error": "Token expired"
}
```

### Error Codes

- `400` - Bad Request (missing parameters)
- `401` - Unauthorized (invalid credentials/token)
- `403` - Forbidden (blacklisted user, no role)
- `500` - Internal Server Error

### cURL Examples

**Login:**
```bash
curl -X POST http://localhost:4000/api/login \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "admin123"}'
```

**Verify Token:**
```bash
curl -X POST http://localhost:4000/api/verify \
  -H "Content-Type: application/json" \
  -d '{"token": "YOUR_JWT_TOKEN_HERE"}'
```

## LiveView Interface

The project includes a modern LiveView login interface with:

- **Real-time Validation**: Instant feedback on form inputs
- **Responsive Design**: Works on desktop and mobile
- **Error Handling**: Clear error messages and success notifications
- **JWT Token Display**: Shows generated tokens for testing
- **Modern UI**: Built with Tailwind CSS and Surface components

### Features

- Email/Username field with format validation
- Password field with strength requirements
- Real-time validation feedback
- Success/error notifications
- JWT token display after successful login
- Responsive design for all screen sizes

### Form Validation Rules

**Username/Email:**
- Must be valid email format OR
- Must contain only letters, numbers, and underscores

**Password:**
- Minimum 8 characters
- Must contain letters, numbers, and underscores only
- No special characters except underscore

## Security Features

### JWT Token Security

- **Algorithm**: HS256 (HMAC SHA-256)
- **Expiration**: Configurable (default: 1 hour)
- **Secret**: Environment variable (change in production!)
- **Claims**: User ID, role, expiration time

### Password Security

- **Hashing**: PBKDF2-SHA512 with 160,000 iterations
- **Salt**: Unique per user
- **Validation**: Server-side and client-side validation

### User Blacklisting

- **Database-backed**: Persistent across sessions
- **Reason Tracking**: Store blacklist reasons
- **Timestamp**: Track when user was blacklisted
- **API Integration**: Automatic rejection of blacklisted users

### CSRF Protection

- **Token Validation**: All forms include CSRF tokens
- **Session Security**: Signed cookies
- **LiveView Integration**: Automatic CSRF handling

## Testing

The project includes comprehensive test coverage with 100+ test cases:

### Test Categories

1. **API Tests** (`test/jwt_auth_project_web/controllers/`)
   - Authentication endpoints
   - Token verification
   - Error handling
   - User blacklisting
   - Role validation

2. **JWT Module Tests** (`test/jwt_auth_project/jwt_auth_test.exs`)
   - Token generation
   - Token verification
   - Expiration handling
   - Blacklist checking
   - Error scenarios

3. **LiveView Tests** (`test/jwt_auth_project_web/live/`)
   - Form rendering
   - User interactions
   - Validation feedback
   - Success/error states

4. **Utils Tests** (`test/jwt_auth_project/utils_test.exs`)
   - Validation functions
   - URL parsing
   - Error message formatting

5. **Account Tests** (`test/jwt_auth_project/accounts_test.exs`)
   - User creation
   - Password validation
   - Role management
   - Blacklist operations

### Running Tests

**All Tests:**
```bash
mix test
```

**Specific Test File:**
```bash
mix test test/jwt_auth_project_web/controllers/auth_controller_test.exs
```

**With Coverage:**
```bash
mix test --cover
```

**Test Runner Script:**
```bash
./run_tests.sh
```

### Test Database Setup

For database-backed tests:

1. **Create test database:**
   ```bash
   MIX_ENV=test mix ecto.create
   MIX_ENV=test mix ecto.migrate
   ```

2. **Configure test environment** in `config/test.exs`

3. **Run tests:**
   ```bash
   mix test
   ```

## Deployment

### Production Configuration

1. **Environment Variables:**
   ```bash
   export DATABASE_URL="postgresql://user:pass@host/database"
   export SECRET_KEY_BASE="your_secret_key_base"
   export JWT_SECRET="your_jwt_secret"
   export PHX_HOST="your-domain.com"
   export PORT=4000
   ```

2. **Database Setup:**
   ```bash
   MIX_ENV=prod mix ecto.migrate
   MIX_ENV=prod mix run priv/repo/seeds.exs
   ```

3. **Asset Compilation:**
   ```bash
   MIX_ENV=prod mix assets.deploy
   ```

4. **Release Build:**
   ```bash
   MIX_ENV=prod mix release
   ```

### Docker Deployment

Create a `Dockerfile`:

```dockerfile
FROM elixir:1.18-alpine

RUN apk add --no-cache build-base git nodejs npm

WORKDIR /app

COPY mix.exs mix.lock ./
RUN mix deps.get --only prod

COPY assets/package.json assets/
RUN npm install --prefix assets

COPY . .
RUN mix assets.deploy
RUN mix compile

RUN mix release

EXPOSE 4000

CMD ["bin/jwt_auth", "start"]
```

### Security Checklist

- [ ] Change default JWT secret
- [ ] Use HTTPS in production
- [ ] Set secure cookie options
- [ ] Configure proper database permissions
- [ ] Set up monitoring and logging
- [ ] Regular security updates
- [ ] Database backup strategy

## Project Structure

```
jwt_auth/
├── lib/
│   ├── jwt_auth_project/
│   │   ├── accounts/          # User and role management
│   │   │   ├── accounts_test.exs
│   │   │   └── accounts.ex
│   │   ├── jwt_auth.ex        # JWT token handling
│   │   └── utils.ex           # Validation utilities
│   └── jwt_auth_project_web/
│       ├── controllers/       # API endpoints
│       ├── live/             # LiveView interfaces
│       ├── components/       # Surface components
│       └── plugs/            # Custom plugs
├── test/                     # Comprehensive test suite
├── priv/
│   ├── repo/migrations/      # Database migrations
│   └── static/              # Static assets
├── assets/                   # Frontend assets
└── config/                   # Configuration files
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For issues and questions:

1. Check the test suite for usage examples
2. Review the API documentation
3. Check existing issues
4. Create a new issue with detailed information

## Changelog

### Latest Updates

- ✅ Comprehensive test suite (100+ tests)
- ✅ LiveView login interface with real-time validation
- ✅ User blacklisting functionality
- ✅ Role-based access control
- ✅ JWT token expiration handling
- ✅ Modern UI with Tailwind CSS
- ✅ Database migrations and seeds
- ✅ Security improvements
- ✅ API documentation with cURL examples
- ✅ Deployment instructions

---

**Built with ❤️ using Elixir, Phoenix, and PostgreSQL**
