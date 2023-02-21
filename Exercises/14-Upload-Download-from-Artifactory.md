# Upload and Download Artifacts from Artifactory

> **Note:** This example requires an active Artifactory account. If you do not
> have one, you can sign up for a free trial
> [here](https://jfrog.com/start-free/).

If your project produces build artifact(s) that are needed by other projects or
users, the
[`actions/upload-artifact`](https://github.com/actions/upload-artifact) and
[`actions/download-artifact`](https://github.com/actions/download-artifact)
actions can help with this process. If your team is using Artifactory, you can
also use the
[JFROG CLI Action](https://github.com/marketplace/actions/jfrog-cli) to connect
to Artifactory and run various CLI commands.

## Create Artifactory credential secrets

Before we can interact with Artifactory, GitHub Actions needs credentials to
access the service. In this step, we will create several secrets that will be
used to authenticate with Artifactory.

1. Open this repository on GitHub.com and navigate to the **Settings** tab
2. In the **Security** section, expand **Secrets and variables**
3. Select **Actions**

Complete the following set of steps for each of the listed secrets:

1. Select **New repository secret**
2. In the **Name** text field, enter the name of the secret (the `Name` column
   in the table below)
3. In the **Secret** text field, enter the value of the secret (examples are
   provided in the the `Example` column in the table below)

| Name               | Value                                             | Description                                                               |
| ------------------ | ------------------------------------------------- | ------------------------------------------------------------------------- |
| `SERVER_URL`       | `https://jfrogy.com/artifactory`                  | The URL of the Artifactory server                                         |
| `SERVER_ID`        | `jfrogy`                                          | The name of the Artifactory server                                        |
| `DISTRIBUTION_URL` | `https://jfrogy.com/artifactory`                  | The URL of the Artifactory distribution server                            |
| `ACCESS_TYPE`      | `username-password`, `access-token`, or `api-key` | The type of authentication to use with Artifactory                        |
| `USERNAME`         | `jfrog`                                           | (`username-password` authentication) The username to use with Artifactory |
| `PASSWORD`         | `P@ssw0rd1`                                       | (`username-password` authentication) The password to use with Artifactory |
| `ACCESS_TOKEN`     | `ABC123`                                          | (`access-token` authentication) The access token to use with Artifactory  |
| `API_KEY`          | `DEF456`                                          | (`api-key` authentication) The API key to use with Artifactory            |

## Update the Continuous Integration workflow

1. Create a branch named `artifactory`

   ```bash
   git checkout -b artifactory
   ```

2. In the `.github/workflows/` directory, open the file named `ci.yml` and
   update it to the following contents

   > **Note:** Please update the path to an artifact that was created in the
   > build process.

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

     # Upload to Artifactory
     upload-artifactory:
       # Name the job
       name: Upload to Artifactory

       uses: Deepakanandrao/jfrog-cli@v3
       with:
         # Commands to run
         cli_cmd: |
           'jfrog rt u "(*).tar" my-local-repo/{1}/ --recursive=false'
         # Environment variables
         env:
           # Required (e.g. https://jfrogy.com/artifactory)
           SERVER_URL: ${{ secrets.SERVER_URL }}

           # Optional - Name to be identify the server with
           SERVER_ID: ${{ secrets.SERVER_ID }}

           # Optional - Distribution URL
           DISTRIBUTION_URL: ${{ secrets.SERVER_URL }}

           # Required  ('username-password', 'access-token', or 'api-key')
           ACCESS_TYPE: ${{ secrets.ACTION_TYPE }}

           # One of the following is required based on ACCESS_TYPE
           # 'username-password'
           USERNAME: ${{ secrets.USERNAME }}
           PASSWORD: ${{ secrets.PASSWORD }}

           # 'access-token'
           ACCESS_TOKEN: ${{ secrets.ACCESS_TOKEN }}

           # 'api-key'
           API_KEY: ${{ secrets.API_KEY }}

     # Download from Artifactory
     download-artifactory:
       # Must run after the upload-artifactory job
       needs: upload-artifactory

       # Name the job
       name: Download from Artifactory

       uses: Deepakanandrao/jfrog-cli@v3
       with:
         # Commands to run
         cli_cmd: |
           'jfrog rt dl my-local-repo/myimage.tar'
         # Environment variables
         env:
           # Required (e.g. https://jfrogy.com/artifactory)
           SERVER_URL: ${{ secrets.SERVER_URL }}

           # Optional - Name to be identify the server with
           SERVER_ID: ${{ secrets.SERVER_ID }}

           # Optional - Distribution URL
           DISTRIBUTION_URL: ${{ secrets.SERVER_URL }}

           # Required  ('username-password', 'access-token', or 'api-key')
           ACCESS_TYPE: ${{ secrets.ACTION_TYPE }}

           # One of the following is required based on ACCESS_TYPE
           # 'username-password'
           USERNAME: ${{ secrets.USERNAME }}
           PASSWORD: ${{ secrets.PASSWORD }}

           # 'access-token'
           ACCESS_TOKEN: ${{ secrets.ACCESS_TOKEN }}

           # 'api-key'
           API_KEY: ${{ secrets.API_KEY }}
   ```

3. Commit the file

   ```bash
   git add .
   git commit -m 'Add artifactory jobs'
   ```

4. Open a pull request and merge the `artifactory` branch into the `main`
   branch, making sure to delete the `artifactory` branch after doing so

   In the pull request, you will see the _Continuous Integration / Upload to
   Artifactory_ job running and the results when it completes. Once it
   completes, the _Continuous Integration / Download from Artifactory_ job will
   start. You can review the logs of the run and the steps it took by selecting
   **Details** next to the action. You can experiment with this action by making
   additional updates to the code and committing it.
