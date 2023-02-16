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

4. Open a pull request to merge the `ct` branch into the `main` branch

   In the pull request, you will see the _Continuous Testing_ workflow running
   and the results when it completes. You can review the logs of the run and the
   steps it took by selecting **Details** next to the action. You can experiment
   with this action by making additional updates to the code and committing it.

   For now, we will ignore Super Linter and merge the pull request.

5. Select **Merge pull request**
6. Select **Close pull request**
7. Select **Delete branch**
