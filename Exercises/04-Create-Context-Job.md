# Create a Context Job

GitHub Actions stores information about the job, environment, and more in
different
[_contexts_](https://docs.github.com/en/actions/learn-github-actions/contexts).
When a workflow runs, different contexts are made available to the workflow
itself and any job(s) or step(s) it defines.

1. Create a branch named `context`

   ```bash
   git checkout -b context
   ```

1. In the `.github/workflows/` directory, create a file named `context.yml` with
   the following contents

   ```yaml
   name: Output GitHub Actions Contexts

   on:
     # Start the workflow on push
     push:
       # Don't run on push to main
       branches-ignore:
         - main

   jobs:
     context:
       # Set the platform to run on
       runs-on: ubuntu-latest

       # Define the steps
       steps:
         - name: Output GitHub Context
           env:
             GITHUB_CONTEXT: ${{ toJson(github) }}
           run: echo "$GITHUB_CONTEXT"
         - name: Output Job Context
           env:
             JOB_CONTEXT: ${{ toJson(job) }}
           run: echo "$JOB_CONTEXT"
         - name: Output Step Context
           env:
             STEPS_CONTEXT: ${{ toJson(steps) }}
           run: echo "$STEPS_CONTEXT"
         - name: Output Runner Context
           env:
             RUNNER_CONTEXT: ${{ toJson(runner) }}
           run: echo "$RUNNER_CONTEXT"
         - name: Output Strategy Context
           env:
             STRATEGY_CONTEXT: ${{ toJson(strategy) }}
           run: echo "$STRATEGY_CONTEXT"
         - name: Output Matrix Context
           env:
             MATRIX_CONTEXT: ${{ toJson(matrix) }}
           run: echo "$MATRIX_CONTEXT"
   ```

1. Commit the file

   ```bash
   git add .
   git commit -m 'Add context workflow'
   ```

1. Open a pull request and merge the `context` branch into the `main` branch,
   making sure to delete the `context` branch after doing so

   In the pull request, you will see the _Output GitHub Actions Contexts_
   workflow running and the results when it completes. You can review the logs
   of the run and the steps it took by selecting **Details** next to the action.
   You can experiment with this action by making additional updates to the code
   and committing it.
