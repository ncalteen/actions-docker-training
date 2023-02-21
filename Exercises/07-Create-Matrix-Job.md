# Create a Matrix Job

In some cases, you may want to run the same job multiple times with different
platforms, dependency versions, or other configurations. GitHub Actions allows
you create matrix jobs to run multiple steps in parallel based on a _matrix_ of
values.

1. Create a branch named `matrix`

   ```bash
   git checkout -b matrix
   ```

2. In the `.github/workflows/` directory, create a file named `matrix.yml` with
   the following contents

   ```yaml
   name: Matrix Build

   on:
     # Start the job on push
     push:
       # Don't run on push to main
       branches-ignore:
         - main

   jobs:
     parallel-test:
       # Define the strategy
       # This will cause the job to run for each combination of `test` and `os`
       # E.g. (test1, macos-latest), (test2, macos-latest), ...
       strategy:
         matrix:
           test: ['test1', 'test2', 'test3']
           os: [macos-latest, ubuntu-latest, windows-latest]

       # Set the platform to run on
       # Populated from the matrix values
       runs-on: ${{ matrix.os }}

       # Define the steps
       steps:
         - name: Test ${{ matrix.test }} on ${{ matrix.os }}
           run: |
             echo "Running test: ${{ matrix.test }}"
             date
             echo "Taking a quick nap..."
             sleep 5
             date
   ```

3. Commit the file

   ```bash
   git add .
   git commit -m 'Add matrix workflow'
   ```

4. Open a pull request and merge the `matrix` branch into the `main` branch,
   making sure to delete the `matrix` branch after doing so

   In the pull request, you will see the _Matrix Build_ workflow running and the
   results when it completes. You will see that 9 jobs are created, one for each
   combination of `test` and `os` from the matrix. You can review the logs of
   the run and the steps it took by selecting **Details** next to the action.
   You can experiment with this action by making additional updates to the code
   and committing it.
