# Reusable Workflows Job

**GitHub Actions** allows you create reusable workflows to centralize and help your team not have to maintain the same workflow over and over.

This allows the user to be able to set up jobs that have various parts that run on different machines, or on the same machine at the same time.
This gives the users more flexibility on how they could semi-automate the deploy/release process.
This give admin the ability to maintain and update a central structure and have all downstream consume.

**Note:** You will likely need to update the repository settings to enable workflow calls:

- **Settings**
  - **Actions**
  - **Access**
  - `Accessible by any repository in the organization`
  - **Save**

You can now create the job below:

1. branch called `central-job`
1. Create a file, `.github/workflows/centralized.yml`
1. Copy the following code:

> **:warning: Note:** This job is primarily used for manual triggers.

```yaml
# This is a basic workflow to help you get started with Actions
name: Centralized Build

# Set the job to run manually
on:
  push:
    branches-ignore: main

# A workflow run is made up of one or more jobs that can run sequentially or in parallel
jobs:
  centralized-job:
    uses: samueljmello/centralized-workflow/.github/workflows/test.yml@main
    with:
      VAR: "static"
```

1. Open a pull request and merge the `central-job` branch into the `main` branch.
