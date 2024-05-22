#!/bin/bash

### Script for balancing cypress tests in docker containers ###

# Function that will start docker containers and will give em
# tests for execution, also kills a container
run_cypress_test() {
    local test_file=$1
    local container_id

    if ! container_id=$(docker run -d cypress-image cypress run --spec "$test_file"); then
        echo "Failed to start container for $test_file"
        return 1
    fi
    
    if ! docker wait "$container_id"; then
        echo "Failed to wait for container $container_id"
        docker rm -f "$container_id"
        return 1
    fi
    
    if ! docker cp "$container_id:/app/cypress/reports/mocha/." "cypress/reports/mocha"; then
        echo "Failed to copy data from container $container_id"
        docker rm -f "$container_id"
        return 1
    fi
    
    if ! docker rm -f "$container_id"; then
        echo "Failed to remove $container_id"
        return 1
    fi
}

rm -rf cypress/reports
mkdir cypress/reports

# Getting all the tests from the project to the pool
ALL_TESTS=$(find . -name "*.cy.js")
MAX_CONTAINERS=3

declare -a PIDS=()

# For loop that will go through each single test and call run_tests func
for test in $ALL_TESTS; do
    run_cypress_test "$test" &
        PIDS+=("$!")

    if [ "${#PIDS[@]}" -ge "${MAX_CONTAINERS}" ]; then
        wait -n
        for i in "${!PIDS[@]}"; do
            if ! kill -0 "${PIDS[i]}" 2>/dev/null; then
                unset "PIDS[i]"
            fi
        done
        PIDS=("${PIDS[@]}")
    fi
done


# Wait for all containers
wait "${PIDS[@]}"

# Report generation and html file generation
npm run combine-reports && npm run generate-report