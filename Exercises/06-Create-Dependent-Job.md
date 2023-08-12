# Create a Dependent Job

By default, GitHub Actions will attempt to run jobs in parallel to decrease
workflow duration. However, there may be cases where you want certain jobs to
complete before others are started. For example, installing dependencies before
running a build. GitHub Actions allows you specify dependencies between jobs so
that certain jobs will not start until others complete successfully.

> **:warning: NOTE:** If a job fails, all jobs that depend on it will be
> skipped.

1. Create a branch named `dependent`
1. In the `.github/workflows/` directory, create a file named `dependent.yml`
   with the following contents

   ```yaml
   name: Dependent Jobs

   on:
     # Start the workflow on push
     push:
       # Don't run on push to main
       branches-ignore:
         - main

   jobs:
     setup:
       # Set the platform to run on
       runs-on: ubuntu-latest

       # Define the steps
       steps:
         - run: |
             sudo apt-get install git-lfs;
             git-lfs --version

     build:
       # Depends on the setup job
       needs: setup

       # Set the platform to run on
       runs-on: ubuntu-latest

       # Define the steps
       steps:
         - run: |
             echo "Hello, World!";
             echo "Goodnight, Moon!";

     test:
       # Depends on the build job
       needs: build

       # Set the platform to run on
       runs-on: ubuntu-latest

       # Define the steps
       steps:
         - run: |
             echo "This is the test step!";
             echo "We should be running tests...";
   ```

1. Commit the file

   ```bash
   git add .
   git commit -m 'Add dependent jobs workflow'
   ```

1. Open a pull request and merge the `dependent` branch into the `main` branch,
   making sure to delete the `dependent` branch after doing so

   In the pull request, you will see the _Dependent Jobs_ workflow running and
   the results when it completes. You can review the logs of the run and the
   steps it took by selecting **Details** next to the action. You will see that,
   unlike other workflows you created, the jobs do not run at the same time.
   Instead, the `build` job only starts once `setup` completes, and the `test`
   job only starts once `build` completes.
