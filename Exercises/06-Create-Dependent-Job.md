# GitHub Dependent Job

**GitHub Actions** allows you link jobs and make then dependent on the previous job outlined in the workflow.

This allows the user to be able to set up jobs that have various parts that run  on different machines, or on the same machine.
This gives the users more flexibility on how they could semi-automate the deploy/release process.

1. Create a branch called `dependent-job`
1. Create a file, `.github/workflows/dependent.yml`
1. Copy the following code:

> **:warning: Note:** This job is primarily used for manual triggers.

```yaml
# This is a basic workflow to help you get started with Actions
name: Dependent Build

# Set the job to run manually
on:
  push:
    branches-ignore: main

jobs:
  setup:
    runs-on: ubuntu-latest
    steps:
      - run: |
          sudo apt-get install git-lfs;
          git-lfs --version

  build:
    needs: setup
    runs-on: ubuntu-latest
    steps:
      - run: |
          echo "Hello World";
          echo "Goodnight Moon!";
  test:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - run: |
          echo "This is the test steps!";
          echo "We should be running tests";
          echo "such test, much wow...";
```

1. Open a pull request and merge the `dependent-job` branch into the `main` branch.
