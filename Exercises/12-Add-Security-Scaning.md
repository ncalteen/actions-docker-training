# Add Security Scaning

Incorporating security scanning into your repository enables constant feedback
on potential security risks in your codebase. GitHub provides a CodeQL action to
provide semantic code analysis as part of your development workflow. Whenever a
developer submits new code, the action will run a security scan on the code and
provide feedback on any potential security risks.

[`github/codeql-action`](https://github.com/github/codeql-action)

1. Create a branch named `security`

   ```bash
   git checkout -b security
   ```

2. In the `.github/workflows/` directory, create a file named `security.yml`
   with the following contents

   ```yml
   name: CodeQL Security Analysis

   on:
     # Start the job on push
     push:
       # Don't run on push to main
       branches-ignore:
         - 'main'

   jobs:
     scan:
       # Name the job
       name: CodeQL Analysis

       # Set the platform to run on
       runs-on: ubuntu-latest

       # Define the steps
       steps:
         # Checkout the codebase
         - name: Checkout
           uses: actions/checkout@v3
           with:
             # Full git history is needed to get a
             # proper list of changed files
             fetch-depth: 0

         # Initialize CodeQL
         - name: Initialize CodeQL
           uses: github/codeql-action/init@v2
           with:
             languages: python

         # Run CodeQL analysis
         - name: Perform CodeQL Analysis
           uses: github/codeql-action/analyze@v2
   ```

3. Commit the file

   ```bash
   git commit -am 'Add security workflow'
   ```

4. Open a pull request and merge the `security` branch into the `main` branch,
   making sure to delete the `security` branch after doing so

   In the pull request, you will see the _CodeQL Security Analysis_ workflow
   running and the results when it completes. You can review the logs of the run
   and the steps it took by selecting **Details** next to the action. You can
   experiment with this action by making additional updates to the code and
   committing it.
