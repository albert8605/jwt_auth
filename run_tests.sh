#!/bin/bash

# Test Runner for JWT Authentication Project

echo "JWT Authentication Project - Test Runner"
echo "========================================"

case "$1" in
  "all")
    echo "Running all tests..."
    mix test
    ;;
  "unit")
    echo "Running unit tests..."
    mix test test/jwt_auth_project/
    ;;
  "integration")
    echo "Running integration tests..."
    mix test test/jwt_auth_project_web/
    ;;
  "api")
    echo "Running API tests..."
    mix test test/jwt_auth_project_web/controllers/auth_controller_test.exs
    ;;
  "liveview")
    echo "Running LiveView tests..."
    mix test test/jwt_auth_project_web/live/
    ;;
  "coverage")
    echo "Running tests with coverage..."
    mix test --cover
    ;;
  "clean")
    echo "Cleaning test artifacts..."
    rm -rf test_reports cover
    mix clean
    ;;
  *)
    echo "Usage: $0 {all|unit|integration|api|liveview|coverage|clean}"
    echo ""
    echo "Commands:"
    echo "  all         Run all tests"
    echo "  unit        Run unit tests only"
    echo "  integration Run integration tests only"
    echo "  api         Run API controller tests only"
    echo "  liveview    Run LiveView tests only"
    echo "  coverage    Run tests with coverage report"
    echo "  clean       Clean test artifacts"
    exit 1
    ;;
esac 