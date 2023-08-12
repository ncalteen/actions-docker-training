# Use GitHub's Deployment API to Update Environments

> **Note:** This exercise makes use of the
> [`bobheadxi/deployments`](https://github.com/bobheadxi/deployments) action to
> work with deployment statuses. This is an open source action that is not
> maintained by GitHub. Please review the action's source code before using it
> in your own workflows.

This exercise will walk you through utilizing GitHub's
[Deployment API](https://docs.github.com/en/rest/deployments/deployments). The
Deployment API is used to manage deployments and deployment environments.
Whenever a deployment occurs, GitHub will send a `deployment` event to any
external services you have configured. This event will contain information about
the deployment, including the environment, the status, and the commit SHA. You
can use this information to update your deployment environments within GitHub
Actions or other external services.

> **Note:** This exercise builds off [Exercise 16](./16-Deploy-Docker.md). If
> you have not completed that exercise, please do so before continuing.

## Update your Workflow

1. Create a new branch named `deployment-api`

   ```bash
   git checkout -b deployment-api
   ```

1. Open one of the following workflow files you created previously:
   - `deploy-prod-docker.yml`
   - `deploy-prod-gcr.yml`
   - `deploy-prod-ecr.yml`
1. Add the following as the **first** step in the workflow

   ```yml
   # Set the deployment status to started
   - name: Start Deployment
     id: deployment
     uses: bobheadxi/deployments@v1
     with:
       step: start
       token: ${{ secrets.GITHUB_TOKEN }}
       env: production
   ```

1. Add the following as the **last** step in the workflow

   ```yml
   # Update deployment status
   - name: Update Deployment Status
     uses: bobheadxi/deployments@v1
     if: always()
     with:
       step: finish
       token: ${{ secrets.GITHUB_TOKEN }}
       status: ${{ job.status }}
       deployment_id: ${{ steps.deployment.outputs.deployment_id }}
       env_url: https://github.com/orgs/${{github.repository_owner}}/packages?repo_name=${{github.repository.name}}
       env: production
   ```

1. Commit the file

   ```bash
   git add .
   git commit -m "Add deployment status updates"
   ```

1. Open a pull request and merge the `deployment-api` branch into the `main`
   branch, making sure to delete the `deployment-api` branch after doing so

   When the workflow starts, you will see a notification in the pull request
   that the branch is being deployed. When the workflow completes, you will see
   a notification that the deployment was successful.

1. In your repository, select the **Code** tab
1. In the right section, select the **production** environment
1. Select **View deployment**

   Here you will be directed to the destination of the deployment. In this
   exercise, this is the list of "production-ready" container images that have
   been deployed.
