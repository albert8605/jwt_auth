#!/usr/bin/env elixir

# Test Runner for JWT Authentication Project
# Usage: elixir test_runner.exs [options]

defmodule TestRunner do
  @moduledoc """
  Test runner for the JWT authentication project.
  Provides various commands to run tests and generate reports.
  """

  def main(args \\ []) do
    case parse_args(args) do
      {:help} ->
        print_help()

      {:all} ->
        run_all_tests()

      {:unit} ->
        run_unit_tests()

      {:integration} ->
        run_integration_tests()

      {:api} ->
        run_api_tests()

      {:liveview} ->
        run_liveview_tests()

      {:coverage} ->
        run_tests_with_coverage()

      {:watch} ->
        run_tests_in_watch_mode()

      {:report} ->
        generate_test_report()

      {:clean} ->
        clean_test_artifacts()

      _ ->
        print_help()
    end
  end

  defp parse_args(args) do
    case args do
      ["--help"] -> {:help}
      ["-h"] -> {:help}
      ["all"] -> {:all}
      ["unit"] -> {:unit}
      ["integration"] -> {:integration}
      ["api"] -> {:api}
      ["liveview"] -> {:liveview}
      ["coverage"] -> {:coverage}
      ["watch"] -> {:watch}
      ["report"] -> {:report}
      ["clean"] -> {:clean}
      _ -> {:help}
    end
  end

  defp print_help do
    IO.puts("""
    JWT Authentication Project - Test Runner

    Usage: elixir test_runner.exs [command]

    Commands:
      all         Run all tests
      unit        Run unit tests only
      integration Run integration tests only
      api         Run API controller tests only
      liveview    Run LiveView tests only
      coverage    Run tests with coverage report
      watch       Run tests in watch mode
      report      Generate test report
      clean       Clean test artifacts
      --help, -h  Show this help message

    Examples:
      elixir test_runner.exs all
      elixir test_runner.exs unit
      elixir test_runner.exs coverage
    """)
  end

  defp run_all_tests do
    IO.puts("Running all tests...")
    System.cmd("mix", ["test"], [stderr_to_stdout: true])
    |> print_result("All tests")
  end

  defp run_unit_tests do
    IO.puts("Running unit tests...")
    System.cmd("mix", ["test", "test/jwt_auth_project/"], [stderr_to_stdout: true])
    |> print_result("Unit tests")
  end

  defp run_integration_tests do
    IO.puts("Running integration tests...")
    System.cmd("mix", ["test", "test/jwt_auth_project_web/"], [stderr_to_stdout: true])
    |> print_result("Integration tests")
  end

  defp run_api_tests do
    IO.puts("Running API tests...")
    System.cmd("mix", ["test", "test/jwt_auth_project_web/controllers/auth_controller_test.exs"], [stderr_to_stdout: true])
    |> print_result("API tests")
  end

  defp run_liveview_tests do
    IO.puts("Running LiveView tests...")
    System.cmd("mix", ["test", "test/jwt_auth_project_web/live/"], [stderr_to_stdout: true])
    |> print_result("LiveView tests")
  end

  defp run_tests_with_coverage do
    IO.puts("Running tests with coverage...")
    System.cmd("mix", ["test", "--cover"], [stderr_to_stdout: true])
    |> print_result("Tests with coverage")
  end

  defp run_tests_in_watch_mode do
    IO.puts("Running tests in watch mode...")
    IO.puts("Press Ctrl+C to stop")
    System.cmd("mix", ["test.watch"], [stderr_to_stdout: true])
    |> print_result("Watch mode tests")
  end

  defp generate_test_report do
    IO.puts("Generating test report...")

    # Run tests and capture output
    {output, exit_code} = System.cmd("mix", ["test", "--cover"], [stderr_to_stdout: true])

    # Create report directory
    File.mkdir_p!("test_reports")

    # Write report
    timestamp = DateTime.utc_now() |> Calendar.strftime("%Y%m%d_%H%M%S")
    report_file = "test_reports/test_report_#{timestamp}.txt"

    File.write!(report_file, """
    JWT Authentication Project - Test Report
    Generated: #{DateTime.utc_now()}

    #{output}
    """)

    IO.puts("Test report generated: #{report_file}")
    print_result({output, exit_code}, "Test report generation")
  end

  defp clean_test_artifacts do
    IO.puts("Cleaning test artifacts...")

    # Remove test reports
    if File.exists?("test_reports") do
      File.rm_rf!("test_reports")
      IO.puts("Removed test_reports directory")
    end

    # Remove coverage files
    if File.exists?("cover") do
      File.rm_rf!("cover")
      IO.puts("Removed cover directory")
    end

    # Clean build artifacts
    System.cmd("mix", ["clean"], [stderr_to_stdout: true])
    |> print_result("Clean")

    IO.puts("Test artifacts cleaned successfully")
  end

  defp print_result({output, exit_code}, test_type) do
    IO.puts("\n" <> String.duplicate("=", 50))
    IO.puts("#{test_type} completed with exit code: #{exit_code}")
    IO.puts(String.duplicate("=", 50))
    IO.puts(output)

    case exit_code do
      0 ->
        IO.puts("\n✅ #{test_type} passed successfully!")
        System.halt(0)
      _ ->
        IO.puts("\n❌ #{test_type} failed!")
        System.halt(exit_code)
    end
  end
end

# Run the test runner if this script is executed directly
if System.argv() != [] do
  TestRunner.main(System.argv())
end
