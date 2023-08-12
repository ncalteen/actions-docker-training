# Add Dependencies Between Jobs

> **Note:** This exercise makes use of the
> [`fountainhead/action-wait-for-check`](https://github.com/fountainhead/action-wait-for-check)
> action to work with action statuses. This is an open source action that is not
> maintained by GitHub. Please review the action's source code before using it
> in your own workflows.

In [Exercise 6: Create a Dependent Job](./06-Create-Dependent-Job.md), you
created a workflow that contained steps that were dependent on one another. This
is an important control that can be used to prevent jobs from running until
certain prerequisites are met.

There may also be times where you want to run one of several jobs based on the
result of a previous job. For example, you may want to create an issue if a
deployment fails so that your team can track their troubleshooting steps.

> **Note:** This exercise builds off [Exercise 16](./16-Deploy-Docker.md). If
> you have not completed that exercise, please do so before continuing.

1. Create a new branch named `conditional`

   ```bash
   git checkout -b conditional
   ```

1. Open one of the following workflow files you created previously:
   - `deploy-prod-docker.yml`
   - `deploy-prod-gcr.yml`
   - `deploy-prod-ecr.yml`
1. Add the following as a **new** job in the workflow

   ```yaml
   check-status:
     # Name the job
     name: Check Release Status

     # Set the platform to run on
     runs-on: ubuntu-latest

     # Define the steps
     steps:
       # Wait for release to finish
       - name: Wait for Release
         uses: fountainhead/action-wait-for-check@v1.1.0
         id: wait-for-release
         with:
           token: ${{ secrets.GITHUB_TOKEN }}
           checkName: Release
           ref: ${{ github.event.pull_request.head.sha || github.sha }}

       # Do something if the deployment was successful
       - name: Success Step
         if: steps.wait-for-release.outputs.conclusion == 'success'
         run: echo "We have success"

       # Do something if the deployment failed
       - name: Failure Step
         if: steps.wait-for-release.outputs.conclusion == 'failure'
         run: echo "ERROR! Release failure!
   ```

1. Commit the file

   ```bash
   git add .
   git commit -m "Add deployment status updates"
   ```

1. Open a pull request and merge the `conditional` branch into the `main`
   branch, making sure to delete the `conditional` branch after doing so

   In the pull request, you will see the _Check Release Status_ workflow running
   and the results when it completes. You can review the logs of the run and the
   steps it took by selecting **Details** next to the action. You can experiment
   with this action by making additional updates to the code and committing it.
