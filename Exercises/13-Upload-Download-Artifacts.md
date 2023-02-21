# Upload and Download Build Artifacts

If your project produces build artifact(s) that are needed by other projects or
users, the
[`actions/upload-artifact`](https://github.com/actions/upload-artifact) and
[`actions/download-artifact`](https://github.com/actions/download-artifact)
actions can help with this process.

In this exercise, we will modify our existing CI workflow to upload the
container image. Then, we will create a new workflow to download the container
image and load it into the Docker service in the action's runtime.

1. Create a branch named `artifacts`

   ```bash
   git checkout -b artifacts
   ```

2. In the `.github/workflows/` directory, open the file named `ci.yml` and
   update it to the following contents

   ```yaml
   name: Continuous Integration

   on:
     # Start the job on push
     push:
       # Don't run on push to main
       branches-ignore:
         - 'main'

   jobs:
     # Build the container
     build:
       # Name the job
       name: Upload Container

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
             tags: super-cool-image:latest
             outputs: type=docker,dest=/tmp/myimage.tar

         # Upload the artifact
         - name: Upload Artifact
           uses: actions/upload-artifact@v3
           with:
             name: myimage
             path: /tmp/myimage.tar

     # Download the container
     download-container:
       # Must run after the build job
       needs: build

       # Name the job
       name: Download Container

       # Set the platform to run on
       runs-on: ubuntu-latest

       # Define the steps
       steps:
         # Setup Docker BuildX
         - name: Setup Docker BuildX
           uses: docker/setup-buildx-action@v2

         # Download the artifact
         - name: Download artifact
           uses: actions/download-artifact@v3
           with:
             name: myimage
             path: /tmp

         # Load the Docker image
         - name: Load image
           run: |
             docker load --input /tmp/myimage.tar
             docker image ls -a
   ```

3. Commit the file

   ```bash
   git add .
   git commit -m 'Add upload/download jobs'
   ```

4. Open a pull request and merge the `artifacts` branch into the `main` branch

   > **:warning: NOTE:** Make sure **not** to delete the `artifacts` branch
   > after merging your pull request. The new action we created won't run until
   > it is merged into `main`. Next, we will create another pull request to test
   > the new action.

5. Synchronize your local repository with the remote

   ```bash
   git pull
   ```

6. In the `library/` directory, open the file named `entrypoint.sh` and add the
   following line to the bottom

   ```bash
   echo "Goodbye from the container!"
   ```

7. Commit the file

   ```bash
   git add .
   git commit -m 'Update Dockerfile'
   ```

8. Open a pull request and merge the `artifacts` branch into the `main` branch,
   making sure to delete the `artifacts` branch after doing so

   In the pull request, you will see the _Continuous Integration / Upload
   Container_ job running and the results when it completes. Once it completes,
   the _Continuous Integration / Download Container_ job will start. You can
   review the logs of the run and the steps it took by selecting **Details**
   next to the action. You can experiment with this action by making additional
   updates to the code and committing it.
