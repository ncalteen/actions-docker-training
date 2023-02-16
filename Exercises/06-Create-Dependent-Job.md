# Create a Dependent Job

By default, GitHub Actions will attempt to run jobs in parallel to decrease
workflow duration. However, there may be cases where you want certain jobs to
complete before others are started. For example, installing dependencies before
running a build. GitHub Actions allows you specify dependencies between jobs so
that certain jobs will not start until others complete successfully.

> **:warning: NOTE:** If a job fails, all jobs that depend on it will be
> skipped.

1. Create a branch named `Depdent`
2. Create a file named `.github/workflows/06-dependent.yml` with the following
   contents

   > **:warning: Note:** This job is primarily used for manual triggers.

   ```yaml
   name: Dependent Jobs

   on:
     # Start the job on push
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
             echo "Hello World";
             echo "Goodnight Moon!";

     test:
       # Depends on the build job
       needs: build

       # Set the platform to run on
       runs-on: ubuntu-latest

       # Define the steps
       steps:
         - run: |
             echo "This is the test steps!";
             echo "We should be running tests";
             echo "such test, much wow...";
   ```

3. Open a pull request and merge the `dependent-job` branch into the `main`
   branch.
