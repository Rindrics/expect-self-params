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

check_param() {
  local PARAM_PATH=$1
  local EXPECTED_VALUE=$2

  ACTUAL_VALUE=$(echo "${WORKFLOW_CONTENT}" | yq e "${PARAM_PATH}" -)

  if [ "${ACTUAL_VALUE}" == "null" ]; then
    echo "The parameter at ${PARAM_PATH} is not set."
    exit 1
  fi

  if [ "${ACTUAL_VALUE}" != "${EXPECTED_VALUE}" ]; then
    echo "Unexpected value at ${PARAM_PATH}"
    echo "  expected: ${EXPECTED_VALUE}"
    echo "  got: ${ACTUAL_VALUE}"
    exit 1
  fi

  echo "Passed"
}

# Parse the JSON input and iterate over the checks
echo "${PARAMS}" | jq -c 'to_entries | .[]' | while read -r entry; do
  KEY=$(echo "${entry}" | jq -r '.key')
  PARAMS=$(echo "${entry}" | jq -r '.value')

  # Check if the key is for a workflow, job, or step
  if [ "${KEY}" == "workflow" ]; then
    echo "${PARAMS}" | jq -c 'to_entries | .[]' | while read -r param; do
      PARAM=$(echo "${param}" | jq -r '.key')
      EXPECTED_VALUE=$(echo "${param}" | jq -r '.value')
      check_param ".${PARAM}" "${EXPECTED_VALUE}"
    done
  elif [[ "${KEY}" == jobs.* ]]; then
    JOB_ID=$(echo "${KEY}" | cut -d. -f2)
    echo "${PARAMS}" | jq -c 'to_entries | .[]' | while read -r param; do
      PARAM=$(echo "${param}" | jq -r '.key')
      EXPECTED_VALUE=$(echo "${param}" | jq -r '.value')
      check_param ".jobs.${JOB_ID}.${PARAM}" "${EXPECTED_VALUE}"
    done
  elif [[ "${KEY}" == steps.* ]]; then
    STEP_ID=$(echo "${KEY}" | cut -d. -f2)
    echo "${PARAMS}" | jq -c 'to_entries | .[]' | while read -r param; do
      PARAM=$(echo "${param}" | jq -r '.key')
      EXPECTED_VALUE=$(echo "${param}" | jq -r '.value')
      check_param ".jobs.test.steps[] | select(.id == \"${STEP_ID}\") | .${PARAM}" "${EXPECTED_VALUE}"
    done
  else
    echo "Unknown key format: ${KEY}"
    exit 1
  fi
done
