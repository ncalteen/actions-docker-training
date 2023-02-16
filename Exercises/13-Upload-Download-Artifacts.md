# Uploading and Downloading build artifacts on Github Workflow

- If your job produces a build artifact that users need to view, or need to be passed to another build machine, the **Github Actions** `upload` and `download` Action can help with this process.

### Exercise: Add Upload and Download

1. Add the following code to your CI build pipeline, and it will then start publishing the artifact once the step has completed.
**Note:** You can copy and paste the whole snippet below into your pipeline. Notice the addional steps to upload and download the artifact.
1. Create a new branch called `Artifacts`
1. Copy and paste the following code snippet into one of your working CI workflow file:
```yaml
---
########
########
## CI ##
########
########
name: Continuous Integration

#
# Documentation:
# https://help.github.com/en/articles/workflow-syntax-for-github-actions
#

#############################
# Start the job on all push #
#############################
# Don't need to run on push to master/main
on:
  push:
    branches-ignore:
      - 'master'
      - 'main'

###############
# Set the Job #
###############
jobs:
  build:
    # Name the Job
    name: CI
    # Set the agent to run on
    runs-on: ubuntu-latest
    ##################
    # Load all steps #
    ##################
    steps:
      ##########################
      # Checkout the code base #
      ##########################
      - name: Checkout Code
        uses: actions/checkout@v2

      ########################
      # Setup Docker build X #
      ########################
      - name: Setup BuildX
        uses: docker/setup-buildx-action@v1

      ##############################
      # Build the docker container #
      ##############################
      - name: Build Docker container
        uses: docker/build-push-action@v2
        with:
          context: .
          file: ./Dockerfile
          build-args: |
            BUILD_DATE=${{ env.BUILD_DATE }}
            BUILD_REVISION=${{ github.sha }}
            BUILD_VERSION=${{ github.sha }}
          push: false
          tags: super-cool-image:latest
          outputs: type=docker,dest=/tmp/myimage.tar

      ###########################################
      # Upload the artifact to the workflow run #
      ###########################################
      - name: Upload Artifact
        uses: actions/upload-artifact@v3
        with:
          name: myimage
          path: /tmp/myimage.tar

  #############################################
  # Second build job to ingest built artifact #
  #############################################
  ConsumeContainer:
    runs-on: ubuntu-latest
    needs: build
    steps:
      #######################
      # Setup docker buildx #
      #######################
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v1
      
      ###############################################
      # Download the artifact from GitHub Artifacts #
      ###############################################
      - name: Download artifact
        uses: actions/download-artifact@v2
        with:
          name: myimage
          path: /tmp

      #########################
      # Load the docker image #
      #########################
      - name: Load image
        run: |
          docker load --input /tmp/myimage.tar
          docker image ls -a
```
> **Note:** Please update the path to an artifact that was created in the build process.

### Linkage
- [Upload Artifact](https://github.com/actions/upload-artifact)
- [Download Artifact](https://github.com/actions/download-artifact)