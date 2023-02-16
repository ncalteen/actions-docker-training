# Create a Context Job

GitHub Actions stores information about the job, environment, and more in
different
[_contexts_](https://docs.github.com/en/actions/learn-github-actions/contexts).
When a workflow runs, different contexts are made available to the workflow
itself and any job(s) or step(s) it defines.

1. Create a branch named `Context`

   ```bash
   git checkout -b Context
   ```

2. Create a file named `.github/workflows/02-context.yml` with the following
   contents

   > **:warning: Note:** This job is primarily used for debugging to show
   > context information in a running job.

   ```yaml
   name: Output GitHub Actions Contexts

   #############################
   # Start the job on push     #
   # Don't run on push to main #
   #############################
   on:
     push:
       branches-ignore:
         - main

   ##################
   # Define the Job #
   ##################
   jobs:
     # Name the Job
     context-info:
       # Set the platform to run on
       runs-on: ubuntu-latest

       ####################
       # Define the Steps #
       ####################
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

3. Commit the file

   ```bash
   git commit -am 'Add context workflow'
   ```

4. Open a pull request and merge the `Context` branch into the `main` branch,
   making sure to delete the `Context` branch after doing so
