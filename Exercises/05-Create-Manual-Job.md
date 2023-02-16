# Create a Manual Job

GitHub Actions allows you to run jobs manually and pass in any needed inputs.
This gives developers the flexability to incorporate manual steps into their
workflows for situations where human intervention is needed.

1. Create a branch named `Manual`

   ```bash
   git checkout -b Manual
   ```

2. Create a file named `.github/workflows/05-manual.yml` with the following
   contents

   > **:warning: NOTE:** This job is primarily used for manual triggers.

   ```yaml
   name: Manual Deployment

   ###################################
   # Start the job on manual trigger #
   ###################################
   on:
     workflow_dispatch:
       #####################
       # Define the Inputs #
       #####################
       inputs:
         branch:
           description: 'Branch to deploy'
           required: true
           default: 'develop'
         app_list:
           description: 'Comma-separated list of apps to deploy'
           required: true
           default: 'App1,App2'

   ##################
   # Define the Job #
   ##################
   jobs:
     # Name the Job
     manual-deployment:
       # Set the platform to run on
       runs-on: ubuntu-latest

       ####################
       # Define the Steps #
       ####################
       steps:
         - run: |
             echo "Running deployment of branch ${{ github.event.inputs.branch }}!"
             echo "- Deploying the following Apps: ${{ github.event.inputs.app_list }}!"
   ```

3. Commit the file

   ```bash
   git commit -am 'Add manual workflow'
   ```

4. Open a pull request and merge the `Manual` branch into the `main` branch,
   making sure to delete the `Manual` branch after doing so
