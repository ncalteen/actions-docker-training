# Create a Manual Job

GitHub Actions allows you to run jobs manually and pass in any needed inputs.
This gives developers the flexability to incorporate manual steps into their
workflows for situations where human intervention is needed.

1. Create a branch named `manual`

   ```bash
   git checkout -b manual
   ```

2. In the `.github/workflows/` directory, create a file named `manual.yml` with
   the following contents

   > **:warning: NOTE:** This job is primarily used for manual triggers.

   ```yaml
   name: Manual Deployment

   on:
     # Start the job on manual trigger
     workflow_dispatch:
       # Define the inputs
       inputs:
         branch:
           description: 'Branch to deploy'
           required: true
           default: 'develop'
         app_list:
           description: 'Comma-separated list of apps to deploy'
           required: true
           default: 'App1,App2'

   # Define the job
   jobs:
     manual-deployment:
       # Set the platform to run on
       runs-on: ubuntu-latest

       # Define the steps
       steps:
         - run: |
             echo "Running deployment of branch ${{ github.event.inputs.branch }}!"
             echo "- Deploying the following Apps: ${{ github.event.inputs.app_list }}!"
   ```

3. Commit the file

   ```bash
   git commit -am 'Add manual workflow'
   ```

4. Open a pull request and merge the `manual` branch into the `main` branch,
   making sure to delete the `manual` branch after doing so
5. Navigate to the **Actions** tab of your repository
6. Select the **Manual Deployment** action
7. Select **Run workflow**
8. Update any input values and select **Run workflow**
9. Select the workflow run that appears
10. Select the **manual-deployment** job
11. Expand the steps to view the logs and verify the inputs were passed in
    correctly
