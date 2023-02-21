# Deploy a Docker Image

In this exercise, we are going to deploy a Docker image to various container
registries.

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
| `DOCKERHUB_PASSWORD`    | `P@ssw0rd1`                                    | Password or access token to authenticate to DockerHub |
| `GCR_USERNAME`          | `gcr-user`                                     | Username to authenticate to GitHub Container Registry |
| `GCR_TOKEN`             | `ABC123`                                       | GitHub PAT with access to GCR                         |
| `AWS_ACCESS_KEY_ID`     | `AKIA1234`                                     | Access key ID to authenticate to AWS                  |
| `AWS_SECRET_ACCESS_KEY` | `ABC123`                                       | Secret access key to authenticate to AWS              |
| `ECR_REGISTRY`          | `https://1234.dkr.ecr.us-east-1.amazonaws.com` | Amazon ECR registry URL                               |
| `ECR_REPOSITORY`        | `myrepo`                                       | Amazon ECR repository                                 |

## Deploy to DockerHub

In this step, we will create a workflow that will build and push the Docker
image to [DockerHub](https://hub.docker.com/).

1. Create a branch named `dockerhub`

   ```bash
   git checkout -b dockerhub
   ```

2. In the `.github/workflows/` directory, create a file named
   `deploy-prod-docker.yml` with the following contents

   > **Note:** This workflow assumes your DockerHub username matches your
   > GitHub.com username. If this is not the case, you will need to update
   > references to `${{ github.actor }}` to use your DockerHub username.

   ```yaml
   name: DockerHub Production

   on:
     # Start the workflow on push
     push:
       # Don't run on push to main
       branches-ignore:
         - 'main'

   jobs:
     # Release to DockerHub
     release:
       # Name the job
       name: Release to DockerHub

       # Set the platform to run on
       runs-on: ubuntu-latest

       # Define the steps
       steps:
         # Checkout the codebase
         - name: Checkout
           uses: actions/checkout@v3

         # Setup Docker BuildX
         - name: Setup Docker BuildX
           uses: docker/setup-buildx-action@v2

         # Log in to DockerHub
         - name: Log in to DockerHub
           uses: docker/login-action@v2
           with:
             username: ${{ secrets.DOCKERHUB_USERNAME }}
             password: ${{ secrets.DOCKERHUB_PASSWORD }}

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
               ${{ github.actor }}/demo-action:latest
               ${{ github.actor }}/demo-action:v1

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
                 body: 'Successfully deployed to production'
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

   When the workflow starts, you will see a notification in the pull request
   that the branch is being deployed. When the workflow completes, you will see
   a notification that the deployment was successful. Additionally, if you
   navigate to the **Issues** tab of your repository, you will see that GitHub
   Actions has generated an issue when the deployment started, and updated the
   issue when the deployment completed.

## Deploy to GitHub Container Registry (GCR)

1. Create a branch named `gcr`

   ```bash
   git checkout -b gcr
   ```

2. In the `.github/workflows/` directory, create a file named
   `deploy-prod-gcr.yml` with the following contents

   ```yaml
   name: GCR Production

   on:
     # Start the workflow on push
     push:
       # Don't run on push to main
       branches-ignore:
         - 'main'

   jobs:
     # Release to GCR
     release:
       # Name the job
       name: Release to GCR

       # Set the platform to run on
       runs-on: ubuntu-latest

       # Define the steps
       steps:
         # Checkout the codebase
         - name: Checkout
           uses: actions/checkout@v3

         # Build the image
         - name: Build Image
           run:
             docker build . --file Dockerfile --tag "${{
             github.event.repository.name }}"  --label "runnumber=${{
             github.run_id }}"

         # Log in to GCR
         - name: Log in to GCR
           run:
             echo "${{ secrets.GITHUB_TOKEN }}" | docker login ghcr.io -u $
             --password-stdin

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

         # Push image to GCR
         - name: Push Image
           run: |
             IMAGE_ID=ghcr.io/${{ github.repository_owner }}/${{ github.event.repository.name }}

             # Change all uppercase to lowercase
             IMAGE_ID=$(echo $IMAGE_ID | tr '[A-Z]' '[a-z]')

             # Strip Git ref prefix from version
             VERSION=$(echo "${{ github.ref }}" | sed -e 's,.*/\(.*\),\1,')

             # Strip "v" prefix from tag name
             [[ "${{ github.ref }}" == "refs/tags/"* ]] && VERSION=$(echo $VERSION | sed -e 's/^v//')

             # Use Docker `latest` tag convention
             [ "$VERSION" == "master" ] && VERSION=latest
             echo IMAGE_ID=$IMAGE_ID
             echo VERSION=$VERSION
             docker tag ${{ github.event.repository.name }} $IMAGE_ID:$VERSION
             docker push $IMAGE_ID:$VERSION

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
                 body: 'Successfully deployed to production'
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
   git commit -m "Add GCR deployment workflow"
   ```

4. Open a pull request and merge the `gcr` branch into the `main` branch, making
   sure to delete the `gcr` branch after doing so

   In the pull request, you will see the _GCR Production_ workflow running and
   the results when it completes. You can review the logs of the run and the
   steps it took by selecting **Details** next to the action. You can experiment
   with this action by making additional updates to the code and committing it.

   When the workflow starts, you will see a notification in the pull request
   that the branch is being deployed. When the workflow completes, you will see
   a notification that the deployment was successful. Additionally, if you
   navigate to the **Issues** tab of your repository, you will see that GitHub
   Actions has generated an issue when the deployment started, and updated the
   issue when the deployment completed.

## Deploy to Amazon Elastic Container Registry (ECR)

1. Create a branch named `ecr`

   ```bash
   git checkout -b gcr
   ```

2. In the `.github/workflows/` directory, create a file named
   `deploy-prod-ecr.yml` with the following contents

   ```yaml
   name: ECR Production

   on:
     # Start the workflow on push
     push:
       # Don't run on push to main
       branches-ignore:
         - 'main'

   jobs:
     # Release to GCR
     release:
       # Name the job
       name: Release to ECR

       # Set the platform to run on
       runs-on: ubuntu-latest

       # Define the steps
       steps:
         # Checkout the codebase
         - name: Checkout
           uses: actions/checkout@v3

         # Setup Docker BuildX
         - name: Setup Docker BuildX
           uses: docker/setup-buildx-action@v2

         # Configure AWS authentication
         - name: Configure AWS Credentials
           uses: aws-actions/configure-aws-credentials@v1-node16
           with:
             aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
             aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
             aws-region: us-east-1

         # Log in to Amazon ECR
         - name: Log in to Amazon ECR
           id: login-ecr
           uses: aws-actions/amazon-ecr-login@v1

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
               ${{ secrets.ECR_REGISTRY }}/${{ secrets.ECR_REPOSITORY }}:latest
               ${{ secrets.ECR_REGISTRY }}/${{ secrets.ECR_REPOSITORY }}:v1

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
                 body: 'Successfully deployed to production'
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
   git commit -m "Add ECR deployment workflow"
   ```

4. Open a pull request and merge the `ecr` branch into the `main` branch, making
   sure to delete the `ecr` branch after doing so

   In the pull request, you will see the _ECR Production_ workflow running and
   the results when it completes. You can review the logs of the run and the
   steps it took by selecting **Details** next to the action. You can experiment
   with this action by making additional updates to the code and committing it.

   If you navigate to the **Issues** tab of your repository, you will see that
   GitHub Actions has generated an issue when the deployment started, and
   updated the issue when the deployment completed.
