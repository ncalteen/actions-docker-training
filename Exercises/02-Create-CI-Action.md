# Create a Continuous Integration (CI) Action

This exercise will walk you through setting up _Continuous Integration (CI)_ on
your repository. The objective of CI is to achieve constant feedback on changes
to your codebase. This is the foundation to automatic testing and deployment of
your codebase.

GitHub Actions runs using workflow files in your repository. The first workflow
we are going to create uses an open-source action called
[`docker/build-push-action`](https://github.com/docker/build-push-action). This
action will try to build the current `Dockerfile` and see if it compiles
successfully.

1. Create a new branch named `ci`

   ```bash
   git checkout -b ci
   ```

2. In the root of the repository, create a new directory named `.github`

   ```bash
   mkdir .github
   ```

3. In the `.github` directory, create a new directory named `workflows`

   ```bash
   mkdir .github/workflows
   ```

4. In the `.github/workflows/` directory, create a file named `ci.yml` with the
   following contents

   ```yaml
   name: Continuous Integration

   on:
     # Start the job on push
     push:
       # Don't run on push to main
       branches-ignore:
         - 'main'

   jobs:
     build:
       # Name the job
       name: CI

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

         # Build the Docker container
         - name: Build Docker Container
           uses: docker/build-push-action@v4
           with:
             context: .
             file: ./Dockerfile
             build-args: |
               BUILD_DATE=${{ env.BUILD_DATE }}
               BUILD_REVISION=${{ github.sha }}
               BUILD_VERSION=${{ github.sha }}
             push: false
   ```

5. Commit the file

   ```bash
   git commit -am "Add CI workflow"
   ```

6. Open a pull request and merge the `ci` branch into the `main` branch, making
   sure to delete the `ci` branch after doing so

   In the pull request, you will see the _Continuous Integration_ workflow
   running and the results when it completes. You can review the logs of the run
   and the steps it took by selecting **Details** next to the action. You can
   experiment with this action by making additional updates to the code and
   committing it.

This workflow file is set up to run when a push is made to any branches in the
repository except for `main`. When we push a change to a branch, the action will
clone the repository code base and build the changes.
