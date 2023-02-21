# Use GitHub Script to Create Issues

The [GitHub Script Action](https://github.com/marketplace/actions/github-script)
is a uses [Octokit](https://github.com/octokit/rest.js) to make calling GitHub's
REST API easy and repeatable. With this action, you can manage issues, create
releases, update endpoints, and more. This exercise is a simple example of
creating and updating an issue using GitHub Scripts.

1. Create a new branch named `script`

   ```bash
   git checkout -b script
   ```

2. In the `.github/workflows/` directory, create a file named `create-issue.yml`
   with the following contents

   ```yaml
   name: Create Issue

   on:
     # Start the workflow on push
     push:
       # Don't run on push to main
       branches-ignore:
         - 'main'
     # Run the workflow manually
     workflow_dispatch:

   jobs:
     build:
       # Set the platform to run on
       runs-on: ubuntu-latest

       # Define the steps
       steps:
         # Checkout the codebase
         - name: Checkout
           uses: actions/checkout@v3

         # Run a single command using the runner's shell
         - name: Run Command
           run: echo 'Hello, World!'

         # Create an issue
         - name: Create Issue
           uses: actions/github-script@v6
           id: create-issue
           with:
             github-token: ${{secrets.GITHUB_TOKEN}}
             script: |
               const create = await github.rest.issues.create({
                 owner: context.repo.owner,
                 repo: context.repo.repo,
                 title: 'New issue created',
                 body: 'Heres some base data'
               })
               console.log('create', create)
               return create.data.number

         # Update the issue
         # Uses the issue number from the previous step
         - name: Update Issue
           uses: actions/github-script@v6
           with:
             github-token: ${{secrets.GITHUB_TOKEN}}
             script: |
               github.rest.issues.createComment({
                 owner: context.repo.owner,
                 repo: context.repo.repo,
                 issue_number: "${{ steps.create-issue.outputs.result }}",
                 title: 'New issue created',
                 body: 'Adding a comment!'
               })
   ```

3. Commit the file

   ```bash
   git add .
   git commit -m "Add GitHub Script workflow"
   ```

4. Open a pull request and merge the `script` branch into the `main` branch,
   making sure to delete the `script` branch after doing so

   In the pull request, you will see the _Create Issue_ workflow running and the
   results when it completes. You can review the logs of the run and the steps
   it took by selecting **Details** next to the action. You can experiment with
   this action by making additional updates to the code and committing it.
   Additionally, a new issue will be created in the **Issues** tab of the
   repository.

5. In your repository, open the **Actions** tab
6. Select the **Create Issue** action
7. Select **Run workflow**, then **Run workflow** again

   This will initiate the workflow again, creating a new issue.

## Reference

- [GitHub Script Action](https://github.com/marketplace/actions/github-script)
- [Octokit Create Issue Documentation](https://octokit.github.io/rest.js#issues-create)
