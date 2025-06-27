# JWT Authentication Project - Test Summary

This document provides a comprehensive overview of all test cases in the JWT authentication project.

## Test Structure

```
test/
├── jwt_auth_project/
│   ├── accounts_test.exs          # User and role management tests
│   ├── jwt_auth_test.exs          # JWT token generation/verification tests
│   └── utils_test.exs             # Utility function tests
├── jwt_auth_project_web/
│   ├── controllers/
│   │   ├── auth_controller_test.exs  # API endpoint tests
│   │   ├── page_controller_test.exs  # Page controller tests
│   │   ├── error_html_test.exs       # Error HTML tests
│   │   └── error_json_test.exs       # Error JSON tests
│   └── live/
│       └── login_test.exs            # LiveView login tests
├── support/
│   ├── conn_case.ex               # Connection test case
│   ├── fixtures/
│   │   └── accounts_fixtures.ex   # Test data fixtures
│   └── test_helpers.ex            # Test helper functions
└── test_helper.exs                # Test configuration
```

## Test Categories

### 1. Unit Tests (`test/jwt_auth_project/`)

#### Accounts Tests (`accounts_test.exs`)
- User creation with password hashing
- User authentication (username/password)
- User authentication (email/password)
- User role management
- User blacklisting functionality
- User retrieval with roles

#### JWT Authentication Tests (`jwt_auth_test.exs`)
- JWT token generation
- JWT token verification
- Token expiration handling
- Blacklisted user rejection
- Role validation in tokens
- Invalid token handling
- Token structure validation

#### Utils Tests (`utils_test.exs`)
- Input validation (username, password, email)
- URL parsing and manipulation
- Cookie and header management
- Error message generation
- Data transformation functions

### 2. Integration Tests (`test/jwt_auth_project_web/`)

#### API Controller Tests (`auth_controller_test.exs`)
- POST `/api/login` endpoint
  - Login with username
  - Login with email
  - Invalid credentials handling
  - Blacklisted user rejection
  - Missing role handling
  - Missing parameters handling

- POST `/api/verify` endpoint
  - Valid token verification
  - Invalid token rejection
  - Expired token handling
  - Blacklisted user rejection
  - Role mismatch detection
  - User not found handling

#### LiveView Tests (`login_test.exs`)
- Login form rendering
- Real-time validation
  - Username/email format validation
  - Password strength validation
  - Special character handling (including underscores)
- Form submission
  - Successful login flows
  - Error handling
  - Remember me functionality
- User state management
  - Blacklisted users
  - Users without roles

## Test Data and Fixtures

### Test Helpers (`support/test_helpers.ex`)
- `create_test_user/1` - Creates test users with default attributes
- `create_user_with_token/1` - Creates user and generates JWT token
- `create_blacklisted_user/1` - Creates blacklisted user for testing
- `create_user_without_role/1` - Creates user without role assignment
- `generate_test_token/2` - Generates valid JWT tokens
- `generate_expired_token/2` - Generates expired JWT tokens
- `generate_blacklisted_token/0` - Generates token for blacklisted user
- `generate_token_without_role/1` - Generates token without role
- `setup_test_data/0` - Creates comprehensive test dataset
- `generate_validation_test_data/0` - Provides validation test cases

### Validation Test Data
- **Valid usernames**: `["user123", "test_user", "User123", "123456", "user"]`
- **Invalid usernames**: `["user-123", "user@123", "user.123", "user 123", "user#123"]`
- **Valid passwords**: `["password123", "pass_word123", "Password123", "12345678", "pass123word"]`
- **Invalid passwords**: `["short", "pass@word", "pass-word", "pass word", "pass#word"]`
- **Valid emails**: `["test@example.com", "user.name@domain.co.uk", "user+tag@example.com", "user123@test-domain.org"]`
- **Invalid emails**: `["invalid-email", "test@", "@example.com", "test..user@example.com", "test@.com"]`

## Running Tests

### Using Mix Commands
```bash
# Run all tests
mix test

# Run specific test file
mix test test/jwt_auth_project/accounts_test.exs

# Run tests with coverage
mix test --cover

# Run tests in watch mode (requires mix_test_watch)
mix test.watch
```

### Using Test Runner Script
```bash
# Make script executable
chmod +x run_tests.sh

# Run all tests
./run_tests.sh all

# Run unit tests only
./run_tests.sh unit

# Run integration tests only
./run_tests.sh integration

# Run API tests only
./run_tests.sh api

# Run LiveView tests only
./run_tests.sh liveview

# Run tests with coverage
./run_tests.sh coverage

# Clean test artifacts
./run_tests.sh clean
```

## Test Configuration

### Database Setup
Tests use a separate test database that is automatically created and cleaned up between test runs. The test configuration is defined in `config/test.exs`.

### Test Environment
- **Database**: PostgreSQL test database
- **Password Hashing**: PBKDF2 with test salt
- **JWT Secret**: Test secret key
- **Timeouts**: Reduced for faster test execution

## Test Coverage Areas

### Core Functionality
- ✅ User authentication (username/email + password)
- ✅ JWT token generation and verification
- ✅ Role-based access control
- ✅ User blacklisting
- ✅ Input validation and sanitization
- ✅ Error handling and responses

### API Endpoints
- ✅ POST `/api/login` - User authentication
- ✅ POST `/api/verify` - Token verification
- ✅ Error responses (400, 401, 403)
- ✅ JSON response formatting

### Web Interface
- ✅ LiveView login form
- ✅ Real-time validation
- ✅ Form submission handling
- ✅ Success/error messaging
- ✅ Remember me functionality

### Security Features
- ✅ Password hashing (PBKDF2)
- ✅ JWT token expiration
- ✅ Blacklist checking
- ✅ Role verification
- ✅ Input sanitization

## Validation Rules Tested

### Username Validation
- ✅ Must contain only letters, numbers, and underscores
- ✅ Cannot be empty
- ✅ Real-time validation feedback

### Password Validation
- ✅ Must be at least 8 characters long
- ✅ Must contain only letters, numbers, and underscores
- ✅ Real-time validation feedback

### Email Validation
- ✅ Must be valid email format
- ✅ Cannot be empty
- ✅ Real-time validation feedback

## Edge Cases Covered

### Authentication Edge Cases
- Invalid credentials
- Non-existent users
- Blacklisted users
- Users without roles
- Expired tokens
- Malformed tokens
- Missing required fields

### Input Validation Edge Cases
- Empty strings
- Special characters (allowed: underscore, disallowed: others)
- Very long inputs
- Unicode characters
- SQL injection attempts
- XSS attempts

### Token Edge Cases
- Expired tokens
- Tokens with wrong algorithm
- Tokens with missing claims
- Tokens with invalid signatures
- Tokens for non-existent users
- Tokens with role mismatches

## Performance Considerations

### Test Performance
- Tests are designed to run quickly
- Database transactions are used for isolation
- Minimal external dependencies
- Parallel test execution where possible

### Production Performance
- JWT token generation/verification is optimized
- Database queries are efficient
- Password hashing uses appropriate work factors
- Input validation is fast and secure

## Continuous Integration

### GitHub Actions (Recommended)
```yaml
name: Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:13
        env:
          POSTGRES_PASSWORD: postgres
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
    steps:
      - uses: actions/checkout@v2
      - uses: erlef/setup-beam@v1
        with:
          elixir-version: '1.14'
          otp-version: '24'
      - run: mix deps.get
      - run: mix test
```

## Troubleshooting

### Common Test Issues

1. **Database Connection Errors**
   ```bash
   # Ensure PostgreSQL is running
   sudo service postgresql start
   
   # Create test database
   mix ecto.create
   mix ecto.migrate
   ```

2. **Test Timeout Issues**
   ```bash
   # Increase timeout for slow tests
   mix test --timeout 30000
   ```

3. **Coverage Report Issues**
   ```bash
   # Clean and rebuild
   mix clean
   mix deps.get
   mix test --cover
   ```

### Debugging Tests
```bash
# Run specific test with detailed output
mix test test/path/to/test.exs --trace

# Run with IEx for debugging
iex -S mix test test/path/to/test.exs
```

## Contributing to Tests

### Adding New Tests
1. Follow the existing test structure
2. Use descriptive test names
3. Include both positive and negative test cases
4. Test edge cases and error conditions
5. Use test helpers for common setup

### Test Naming Convention
- Use descriptive names that explain what is being tested
- Include the expected outcome in the test name
- Group related tests using `describe` blocks

### Example Test Structure
```elixir
describe "function_name" do
  test "should handle valid input" do
    # Test implementation
  end
  
  test "should reject invalid input" do
    # Test implementation
  end
  
  test "should handle edge case" do
    # Test implementation
  end
end
```

This comprehensive test suite ensures the reliability and security of the JWT authentication system. 