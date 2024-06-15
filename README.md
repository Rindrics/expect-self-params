# Expect Self Parameter Action

A GitHub Action to validate that specified parameters in your workflow steps are set to expected values.
This helps ensure that your workflows are configured correctly and consistently.

## Features

- **Validation of Step Parameters**: Ensures that critical step parameters are correctly set
- **Supports Workflow, Job, and Step Levels**: Validate parameters at any level in your workflow
- **Customizable**: Define any parameter and its expected value
- **Easy Integration**: Simple to use in any GitHub Actions workflow

## Usage

To use this action, add it as a step in your workflow and specify the parameters to check.
Below is an example configuration.

### Example Workflow

```yaml
name: Test Expect Self Parameter Action

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Run expect-self-parameter action
        uses: Rindrics/expect-self-params
        with:
          params: >
            {
              "workflow": {
                "on": "[push, pull_request]"
              },
              "jobs.test": {
                "runs-on": "ubuntu-latest"
              },
              "steps.foo": {
                "continue-on-error": "true"
              },
              "steps.bar": {
                "timeout-minutes": "10"
              }
            }

      - id: foo
        run: echo hello
        continue-on-error: false

      - id: bar
        run: sleep 5
        timeout-minutes: 10
```

In this example, the action checks if:
- the `on` field of the workflow is set to `[push, pull_request]`
- the `test` job has `runs-on` set to `ubuntu-latest`
- the `foo` step has `continue-on-error` set to `true`
- the `bar` step has `timeout-minutes` set to `10`

If the parameters do not match the expected values, the workflow will fail, indicating which parameter was incorrect.

## Inputs

### `params`

**Required** The parameters to validate, specified in JSON format.
You can check parameters at the workflow, job, or step level.

Example:
```json
{
  "workflow": {
    "on": "[push, pull_request]"
  },
  "jobs.test": {
    "runs-on": "ubuntu-latest"
  },
  "steps.foo": {
    "continue-on-error": "true"
  },
  "steps.bar": {
    "timeout-minutes": "10"
  }
}
```

## Outputs

None.

## Benefits for Action Developers

This action is particularly useful for GitHub Action developers who want to enforce specific configurations in their workflows.
By using this action, you can ensure that users of your action have set the required parameters correctly.
This helps prevent misconfigurations and ensures that the action behaves as expected.

For example, if your action requires that a certain step has `continue-on-error` set to `true` to handle errors gracefully, you can enforce this configuration by including `expect-self-parameter` in your workflow.

## License

This project is licensed under the MIT License.
