#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Define variables
TEST_PROJECT_DIR="CardValidation.Tests"
TEST_PROJECT_PATH="$TEST_PROJECT_DIR/CardValidation.Tests.csproj"
REPORTS_DIR="/src/reports"
COVERAGE_DIR="$REPORTS_DIR/coverage"
UNIT_TEST_LOG="/src/TestResults/unit-test-results.trx"
E2E_TEST_LOG="/src/TestResults/e2e-test-results.trx"

# 0. Create results and reports directories
mkdir -p /src/TestResults
mkdir -p $REPORTS_DIR
mkdir -p $COVERAGE_DIR

# 1. Run non-E2E tests with code coverage
echo "Running non-E2E tests..."
dotnet test $TEST_PROJECT_PATH --filter "Category!=e2e" \
  --logger "trx;LogFileName=$UNIT_TEST_LOG" \
  --collect:"XPlat Code Coverage" \
  --settings coverlet.runsettings

# 2. Generate Coverage report
echo "Generating Coverage report..."
reportgenerator "-reports:/src/CardValidation.Tests/TestResults/**/coverage.opencover.xml" "-targetdir:$COVERAGE_DIR" "-reporttypes:Html" "-sourcedirs:/src"

# 3. Run E2E tests
echo "Running E2E tests..."
dotnet test $TEST_PROJECT_PATH --filter "Category=e2e" \
  --logger "trx;LogFileName=$E2E_TEST_LOG"

echo "----------------------------------------"
echo "Tests finished and reports generated."
echo
echo "To view the report, open the following URL in your browser:"
echo "Coverage Report:      http://localhost:8080/reports/coverage/index.html"
echo
echo "The main application container will continue running to serve the API and reports."
echo "Press Ctrl+C in the terminal where you ran 'docker-compose up' to stop it."
echo "----------------------------------------"}