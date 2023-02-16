# Create a Continuous Testing (CT) Action

This exercise will walk you through setting up _Continuous Testing (CT)_ on your
repository. The objective of CT is to quickly get feedback on changes to your
codebase.

The action we are use in our workflow is the open-source
[Super Linter](https://github.com/github/super-linter). This action will review
changes to the code and run a linter against it to ensure code sanity.

1. Create a branch named `ct`

   ```bash
   git checkout -b ct
   ```

2. In the `.github/workflows/` directory, create a file named `ct.yml` with the
   following contents

   ```yaml
   name: Continuous Testing

   on:
     # Start the job on push
     push:
       # Don't run on push to main
       branches-ignore:
         - 'main'

   jobs:
     build:
       # Name the job
       name: CT

       # Set the platform to run on
       runs-on: ubuntu-latest

       # Define the steps
       steps:
         # Checkout the codebase
         - name: Checkout
           uses: actions/checkout@v3
           with:
             # Full git history is needed to get a proper
             # list of changed files within `super-linter`
             fetch-depth: 0

         # Run Super Linter
         - name: Lint Code Base
           uses: github/super-linter@v4
           env:
             VALIDATE_ALL_CODEBASE: true
             DEFAULT_BRANCH: main
             GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
   ```

3. Commit the file

   ```bash
   git commit -am 'Add linting workflow'
   ```

When we push a change to a branch, the GitHub Action will clone the repository
code base, and run the Super Linter against the changes.

## Running your GitHub Action

1. Remove super linter to get checks passing.

1. Open a pull request with the `CT` branch into the `main` branch.

   In the pull request, you will see the GitHub Actions job running and its
   results. You can review the logs of the run and the steps it took by clicking
   on **Details** next to the GitHub Action. You can experiment with this
   Action, but making additional updates to the code and committing it.

1. Merge the pull request.
