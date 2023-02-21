# Create a Reusable Action

Up to this point, you have created several workflows and actions within your
repository. This works for a single repository, but what if you have multiple
repositories that need to run the same tasks?

GitHub Actions allows you to centralize and distribute frequently-used actions
in dedicated repositories. These repositories can be public or private and can
be used across your organization. Any updates to the action repository can be
easily incorporated into workflows that consume the action.

## Create a Custom Action

1. Create a new repository named `centralized-workflow`

   > **:warning: NOTE:** You may need to update the repository settings to allow
   > other repositories in your account/organization to use the workflow. See
   > [Managing GitHub Actions settings for a repository](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/enabling-features-for-your-repository/managing-github-actions-settings-for-a-repository)
   > for more information.

2. Clone the repository to your local machine

   > **:warning: NOTE:** Make sure to run this command outside of this
   > repository!

   ```bash
   git clone git@github.com:ncalteen-learning/centrailized-workflow.git
   ```

3. Create a file named `action.yml` with the following content

   ```yaml
   name: 'Centralized Action'
   description: 'Use this action from other workflows in your organization.'

   runs:
     using: 'node16'
     main: 'index.js'
   ```

4. Create a file named `index.js` with the following content

   ```javascript
   async function run() {
     console.log('Hello from a custom action!')
   }

   run()
   ```

5. Commit the files

   ```bash
   git add .
   git commit -m 'Creating custom action'
   git push origin main
   ```

## Consume the Custom Action

Now that you have a custom action available, you can consume it in other
projects. In this section, you will return to your this repository and add a new
workflow that uses the custom action.

1. Create a branch named `centralized`

   ```bash
   git checkout -b centralized
   ```

2. In the `.github/workflows/` directory, create a file named `centralized.yml`
   with the following contents

   > **:warning: NOTE:** Make sure to replace OWNER with your GitHub username or
   > organization name where you created the custom action repository.

   ```yaml
   name: Centralized Action

   on:
     # Start the workflow on push
     push:
       # Don't run on push to main
       branches-ignore:
         - main

   jobs:
     centralized-job:
       # Set the platform to run on
       runs-on: ubuntu-latest

       # Define the steps
       steps:
         - name: Use the Centralized Action
           uses: OWNER/centralized-workflow@main
   ```

3. Commit the file

   ```bash
   git add .
   git commit -m 'Add centralized action workflow'
   ```

4. Open a pull request and merge the `centralized` branch into the `main`
   branch, making sure to delete the `centralized` branch after doing so

   In the pull request, you will see the _Centralized Action_ workflow running
   and the results when it completes. You can review the logs of the run and the
   steps it took by selecting **Details** next to the action. You can experiment
   with this action by making additional updates to the code and committing it.
