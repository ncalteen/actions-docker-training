# Deploy a Docker Image

In this exercise, we are going to deploy a Docker-based application to various
production-like environments.

## Create GitHub Actions Secrets

Before we can interact with different Docker registries, GitHub Actions needs
credentials to access the services. In this step, we will create several secrets
that will be used to authenticate with the registries used in this exercise.

> **Note:** You can skip creating secrets for any registries you do not want to
> work with.

1. Open this repository on GitHub.com and navigate to the **Settings** tab
2. In the **Security** section, expand **Secrets and variables**
3. Select **Actions**

Complete the following set of steps for each of the listed secrets:

1. Select **New repository secret**
2. In the **Name** text field, enter the name of the secret (the `Name` column
   in the table below)
3. In the **Secret** text field, enter the value of the secret (examples are
   provided in the the `Example` column in the table below)

| Name                    | Value                                          | Description                                           |
| ----------------------- | ---------------------------------------------- | ----------------------------------------------------- |
| `DOCKERHUB_USERNAME`    | `docker-user`                                  | Username to authenticate to DockerHub                 |
| `DOCKERHUB_PASSWORD`    | `P@ssw0rd1`                                    | Password to authenticate to DockerHub                 |
| `GCR_USERNAME`          | `gcr-user`                                     | Username to authenticate to GitHub Container Registry |
| `GCR_TOKEN`             | `ABC123`                                       | GitHub PAT with access to GCR                         |
| `AWS_ACCESS_KEY_ID`     | `AKIA1234`                                     | Access key ID to authenticate to AWS                  |
| `AWS_SECRET_ACCESS_KEY` | `ABC123`                                       | Secret access key to authenticate to AWS              |
| `ECR_REGISTRY`          | `https://1234.dkr.ecr.us-east-1.amazonaws.com` | AWS ECR registry URL                                  |
| `ECR_REPOSITORY`        | `myrepo`                                       | AWS ECR repository                                    |

## Deploy to DockerHub

In this step, we will create a workflow that will build and push the Docker
image to [DockerHub](https://hub.docker.com/).

> **Note:** This step makes use of the
> [`bobheadxi/deployments`](https://github.com/bobheadxi/deployments) action to
> work with deployments. This is an open source action that is not maintained by
> GitHub. Please review the action's source code before using it in your own
> workflows.

1. Create a branch named `dockerhub`

   ```bash
   git checkout -b dockerhub
   ```

2. In the `.github/workflows/` directory, create a file named
   `deploy-prod-docker.yml` with the following contents

   > **Note:** Make sure to replace the value of the `DOCKER_ORG` environment
   > variable with an appropriate organization name.

   ```yaml
   name: DockerHub Production

   on:
     # Start the job on push
     push:
       # Don't run on push to main
       branches-ignore:
         - 'main'

   env:
     DOCKER_ORG: myorg # Replace this value!

   jobs:
     # Release to DockerHub
     docker-prod-release:
       # Name the job
       name: Release to DockerHub

       # Set the platform to run on
       runs-on: ubuntu-latest

       # (Optional) Restrict this job to specific users
       # if: github.actor == 'admiralawkbar' || github.actor == 'jwiebalk'

       # Define the steps
       steps:
         # Checkout the codebase
         - name: Checkout
           uses: actions/checkout@v3

         # Setup Docker BuildX
         - name: Setup Docker BuildX
           uses: docker/setup-buildx-action@v2

         # Login to DockerHub
         - name: Login to DockerHub
           uses: docker/login-action@v2
           with:
             username: ${{ secrets.DOCKERHUB_USERNAME }}
             password: ${{ secrets.DOCKERHUB_PASSWORD }}

         # Set the deployment status to started
         - name: Start Deployment
           id: deployment
           uses: bobheadxi/deployments@v1
           with:
             step: start
             token: ${{ secrets.GITHUB_TOKEN }}
             env: production

         # Create an issue with build info
         - name: Create Issue
           id: create-issue
           uses: actions/github-script@v6
           with:
             github-token: ${{secrets.GITHUB_TOKEN}}
             script: |
               const create = await github.rest.issues.create({
                 owner: context.repo.owner,
                 repo: context.repo.repo,
                 title: 'Deploying to production',
                 body: 'Currently deploying...'
               })
               console.log('create', create)
               return create.data.number

         # Build and push container
         - name: Build and Push
           uses: docker/build-push-action@v4
           with:
             context: .
             file: ./Dockerfile
             push: true
             tags: |
               ${{ env.DOCKER_ORG }}/demo-action:latest
               ${{ env.DOCKER_ORG }}/demo-action:v1

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

         # Update issue status (success)
         - name: Update issue success
           uses: actions/github-script@v6
           if: success()
           with:
             github-token: ${{secrets.GITHUB_TOKEN}}
             script: |
               github.rest.issues.createComment({
                 owner: context.repo.owner,
                 repo: context.repo.repo,
                 issue_number: '${{ steps.create-issue.outputs.result }}',
                 title: 'New issue created',
                 body: 'Successful!y deployed production'
               })

         # Update issue status (failure)
         - name: Update issue failure
           uses: actions/github-script@v6
           if: failure()
           with:
             github-token: ${{secrets.GITHUB_TOKEN}}
             script: |
               github.rest.issues.createComment({
                 owner: context.repo.owner,
                 repo: context.repo.repo,
                 issue_number: '${{ steps.create-issue.outputs.result }}',
                 title: 'New issue created',
                 body: 'Failed to deploy to production'
               })
   ```

3. Commit the file

   ```bash
   git add .
   git commit -m "Add DockerHub deployment workflow"
   ```

4. Open a pull request and merge the `dockerhub` branch into the `main` branch,
   making sure to delete the `dockerhub` branch after doing so

   In the pull request, you will see the _DockerHub Production_ workflow running
   and the results when it completes. You can review the logs of the run and the
   steps it took by selecting **Details** next to the action. You can experiment
   with this action by making additional updates to the code and committing it.

---

#### Deploy to GitHub Container Registry

1. Create a new branch called `Deploy`
1. Add the following file to your repository:
   `.github/workflows/deploy-prod-gcr.yml`

<details>
<summary>Click here to add the file</summary>

```yaml
# This is a basic workflow to help you get started with Actions
name: Docker Production

# Controls when the action will run.
on:
  push:
    branches:
      - 'master'
      - 'main'

# A workflow run is made up of one or more jobs that can run sequentially or in parallel
jobs:
  # This workflow contains a single job called "build"
  docker-prod-release:
    # The type of runner that the job will run on
    runs-on: ubuntu-latest
    # You could use the following lines to help make sure only X people start the workflow
    # if: github.actor == 'admiralawkbar' || github.actor == 'jwiebalk'

    # Steps represent a sequence of tasks that will be executed as part of the job
    steps:
      # use checkout v3 action
      - uses: actions/checkout@v3

      # builds the docker image
      - name: Build image
        run:
          docker build . --file Dockerfile --tag "${{
          github.event.repository.name }}" --label "runnumber=${{ github.run_id
          }}"

      # log into registry
      - name: Log in to registry
        run:
          echo "${{ secrets.GITHUB_TOKEN }}" | docker login ghcr.io -u $
          --password-stdin

      # Update deployment API
      - name: start deployment
        uses: bobheadxi/deployments@v0.4.3
        id: deployment
        with:
          step: start
          token: ${{ secrets.GITHUB_TOKEN }}
          env: Production

      # Create a GitHub Issue with the info from this build
      - name: Create GitHub Issue
        uses: actions/github-script@v6
        id: create-issue
        with:
          # https://octokit.github.io/rest.js/v18#issues-create
          github-token: ${{secrets.GITHUB_TOKEN}}
          script: |
            const create = await github.rest.issues.create({
              owner: context.repo.owner,
              repo: context.repo.repo,
              title: "Deploying to production",
              body: 'Currently deploying...'
            })
            console.log('create', create)
            return create.data.number

      ###########################################
      # Build and Push containers to registries #
      ###########################################
      - name: Push image
        run: |
          IMAGE_ID=ghcr.io/${{ github.repository_owner }}/${{ github.event.repository.name }}
          # Change all uppercase to lowercase
          IMAGE_ID=$(echo $IMAGE_ID | tr '[A-Z]' '[a-z]')
          # Strip git ref prefix from version
          VERSION=$(echo "${{ github.ref }}" | sed -e 's,.*/\(.*\),\1,')
          # Strip "v" prefix from tag name
          [[ "${{ github.ref }}" == "refs/tags/"* ]] && VERSION=$(echo $VERSION | sed -e 's/^v//')
          # Use Docker `latest` tag convention
          [ "$VERSION" == "master" ] && VERSION=latest
          echo IMAGE_ID=$IMAGE_ID
          echo VERSION=$VERSION
          docker tag $IMAGE_NAME $IMAGE_ID:$VERSION
          docker push $IMAGE_ID:$VERSION

      # Update Deployment API
      - name: update deployment status
        uses: bobheadxi/deployments@v0.4.3
        if: always()
        with:
          step: finish
          token: ${{ secrets.GITHUB_TOKEN }}
          status: ${{ job.status }}
          deployment_id: ${{ steps.deployment.outputs.deployment_id }}
          env_url: https://github.com/orgs/${{github.repository_owner}}/packages?repo_name=${{github.repository.name}}

      - name: Update issue success
        uses: actions/github-script@v6
        if: success()
        with:
          # https://octokit.github.io/rest.js/v18#issues-create
          github-token: ${{secrets.GITHUB_TOKEN}}
          script: |
            github.rest.issues.createComment({
              owner: context.repo.owner,
              repo: context.repo.repo,
              issue_number: "${{ steps.create-issue.outputs.result }}",
              title: "New issue created",
              body: "Successful!y deployed production"
            })

      - name: Update issue failure
        uses: actions/github-script@v6
        if: failure()
        with:
          # https://octokit.github.io/rest.js/v18#issues-create
          github-token: ${{secrets.GITHUB_TOKEN}}
          script: |
            github.rest.issues.createComment({
              owner: context.repo.owner,
              repo: context.repo.repo,
              issue_number: "${{ steps.create-issue.outputs.result }}",
              title: "New issue created",
              body: "Failed to deploy to production"
            })
```

</details>

- Commit the code
- Open Pull request & merge
- Watch the failure take place
- Fix line 84 by changing the `$IMAGE_NAME` variable reference to point to
  `${{ github.event.repository.name }}`
- Commit changes, open another pull request, and try again.
- Delete the branch.

---

#### Deploy to AWS ECR

1. Create a new branch called `Deploy`
1. Add the following file to your repository:
   `.github/workflows/deploy-prod-aws.yml`

<details>
<summary>Click here to add the file</summary>

```yaml
# This is a basic workflow to help you get started with Actions

name: Docker Production

# Controls when the action will run.
on:
  push:
    branches:
      - 'master'
      - 'main'

# A workflow run is made up of one or more jobs that can run sequentially or in parallel
jobs:
  # This workflow contains a single job called "build"
  docker-prod-release:
    # The type of runner that the job will run on
    runs-on: ubuntu-latest
    # You could use the following lines to help make sure only X people start the workflow
    # if: github.actor == 'admiralawkbar' || github.actor == 'jwiebalk'

    # Steps represent a sequence of tasks that will be executed as part of the job
    steps:
      # Checks-out your repository under $GITHUB_WORKSPACE, so your job can access it
      - name: Checkout source code
        uses: actions/checkout@v2

      #########################
      # Install Docker BuildX #
      #########################
      - name: Install Docker BuildX
        uses: docker/setup-buildx-action@v1

      ####################
      # Config AWS Creds #
      ####################
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v1
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1

      #################
      # Login AWS ECR #
      #################
      - name: Login to Amazon ECR
        id: login-ecr
        uses: aws-actions/amazon-ecr-login@v1

      # Update deployment API
      - name: start deployment
        uses: bobheadxi/deployments@v0.4.3
        id: deployment
        with:
          step: start
          token: ${{ secrets.GITHUB_TOKEN }}
          env: Production

      # Create a GitHub Issue with the info from this build
      - name: Create GitHub Issue
        uses: actions/github-script@v6
        id: create-issue
        with:
          # https://octokit.github.io/rest.js/v18#issues-create
          github-token: ${{secrets.GITHUB_TOKEN}}
          script: |
            const create = await github.rest.issues.create({
              owner: context.repo.owner,
              repo: context.repo.repo,
              title: "Deploying to production",
              body: 'Currently deploying...'
            })
            console.log('create', create)
            return create.data.number

      ###########################################
      # Build and Push containers to registries #
      ###########################################
      - name: Build and push
        uses: docker/build-push-action@v2
        with:
          context: .
          file: ./Dockerfile
          push: true
          tags: |
            ${{ secrets.ECR_REGISTRY }}/${{ secrets.ECR_REPOSITORY }}:latest
            ${{ secrets.ECR_REGISTRY }}/${{ secrets.ECR_REPOSITORY }}:v1

      # Update Deployment API
      - name: update deployment status
        uses: bobheadxi/deployments@v0.4.3
        if: always()
        with:
          step: finish
          token: ${{ secrets.GITHUB_TOKEN }}
          status: ${{ job.status }}
          deployment_id: ${{ steps.deployment.outputs.deployment_id }}
          env_url: https://github.com/orgs/${{github.repository_owner}}/packages?repo_name=${{github.repository.name}}

      - name: Update issue success
        uses: actions/github-script@v6
        if: success()
        with:
          # https://octokit.github.io/rest.js/v18#issues-create
          github-token: ${{secrets.GITHUB_TOKEN}}
          script: |
            github.rest.issues.createComment({
              owner: context.repo.owner,
              repo: context.repo.repo,
              issue_number: "${{ steps.create-issue.outputs.result }}",
              title: "New issue created",
              body: "Successful!y deployed production"
            })

      - name: Update issue failure
        uses: actions/github-script@v6
        if: failure()
        with:
          # https://octokit.github.io/rest.js/v18#issues-create
          github-token: ${{secrets.GITHUB_TOKEN}}
          script: |
            github.rest.issues.createComment({
              owner: context.repo.owner,
              repo: context.repo.repo,
              issue_number: "${{ steps.create-issue.outputs.result }}",
              title: "New issue created",
              body: "Failed to deploy to production"
            })
```

</details>

- Commit the code
- Open Pull request

---
