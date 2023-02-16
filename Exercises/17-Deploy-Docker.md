# Deploy on push to `master` or `main`

In this session, we are going to be deploying the application to various production style environments. This will take the built **Docker** Container and deploy it to one or more of the various environments.

### Exercise: Deploy Docker images

> **Note:** Before you add the code below, you will need to setup **Github Secrets** To help hold credentials and hidden endpoints.

- **DockerHub**
  - `DOCKERHUB_USERNAME` - Username to authenticate to DockerHub
  - `DOCKERHUB_PASSWORD` - Password to authenticate to DockerHub
- **Github Container Registry**
  - `GCR_USERNAME` - Username to authenticate to GitHub
  - `GCR_TOKEN` - GitHub Personal Access Token with access rights to container registry
- **AWS**
  - `AWS_ACCESS_KEY_ID` - Access key id to authenticate to AWS
  - `AWS_SECRET_ACCESS_KEY` - Secret Access key to authenticate to AWS
  - `ECR_REGISTRY` - AWS ECR Registry to push container image
  - `ECR_REPOSITORY` - AWS ECR repository to push container image
---
#### Deploy to DockerHub

1. Create a new branch called `Deploy`
1. Add the following file to your repository: `.github/workflows/deploy-prod-docker.yml`

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

      ######################
      # Login to DockerHub #
      ######################
      - name: Login to DockerHub
        uses: docker/login-action@v1
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_PASSWORD }}

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
            DOCKER_ORG/demo-action:latest
            DOCKER_ORG/demo-action:v1

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

#### Deploy to GitHub Container Registry

1. Create a new branch called `Deploy`
1. Add the following file to your repository: `.github/workflows/deploy-prod-gcr.yml`

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
        run: docker build . --file Dockerfile --tag "${{ github.event.repository.name }}" --label "runnumber=${{ github.run_id }}"

      # log into registry
      - name: Log in to registry
        run: echo "${{ secrets.GITHUB_TOKEN }}" | docker login ghcr.io -u $ --password-stdin

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
- Fix line 84 by changing the `$IMAGE_NAME` variable reference to point to `${{ github.event.repository.name }}`
- Commit changes, open another pull request, and try again.
- Delete the branch.

---

#### Deploy to AWS ECR

1. Create a new branch called `Deploy`
1. Add the following file to your repository: `.github/workflows/deploy-prod-aws.yml`

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
