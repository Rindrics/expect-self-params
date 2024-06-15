#!/bin/bash

set -e

# Extract inputs
PARAMS=$PARAMS
WORKFLOW_FILE=$WORKFLOW_FILE

# Check if the workflow file exists
if [ ! -f "${WORKFLOW_FILE}" ]; then
  echo "Workflow file not found: ${WORKFLOW_FILE}"
  exit 1
fi

# Load the workflow file content
WORKFLOW_CONTENT=$(cat "${WORKFLOW_FILE}")

# Parse the JSON input and iterate over the checks
echo "${PARAMS}" | jq -c 'to_entries | .[]' | while read -r step; do
  STEP_ID=$(echo "${step}" | jq -r '.key')
  PARAMS=$(echo "${step}" | jq -r '.value')

  echo "${PARAMS}" | jq -c 'to_entries | .[]' | while read -r param; do
    PARAM=$(echo "${param}" | jq -r '.key')
    EXPECTED_VALUE=$(echo "${param}" | jq -r '.value')

    # Check the parameter in the workflow file content
    STEP_CONTENT=$(echo "${WORKFLOW_CONTENT}" | yq e ".jobs.test.steps[] | select(.id == \"${STEP_ID}\")" -)

    if [ -z "${STEP_CONTENT}" ]; then
      echo "Step with id ${STEP_ID} not found in the workflow file."
      exit 1
    fi

    echo "Checking step ${STEP_ID} for parameter ${PARAM} with expected value ${EXPECTED_VALUE}"
    echo "Step content: ${STEP_CONTENT}"

    ACTUAL_VALUE=$(echo "${STEP_CONTENT}" | yq e ".${PARAM}" -)

    if [ "${ACTUAL_VALUE}" == "null" ]; then
      echo "The parameter ${PARAM} for step ${STEP_ID} is not set."
      exit 1
    fi

    if [ "${ACTUAL_VALUE}" != "${EXPECTED_VALUE}" ]; then
      echo "Unexpected \"${PARAM}\" for step \"${STEP_ID}\""
      echo "  expected: ${EXPECTED_VALUE}"
      echo "  got: ${ACTUAL_VALUE}"
      exit 1
    fi

    echo "Passed"
  done
done
