# GitHub Matrix Job

**GitHub Actions** allows you create matrix jobs and make your job run multiple steps in parallel.

This allows the user to be able to set up jobs that have various parts that run on different machines, or on the same machine at the same time.
This gives the users more flexibility on how they could semi-automate the deploy/release process.

1. Create a branch called `matrix-job`
1. Create a file, `.github/workflows/matrix.yml`
1. Copy the following code:

> **:warning: Note:** This job is primarily used for manual triggers.

```yaml
# This is a basic workflow to help you get started with Actions
name: Matrix Build

# Set the job to run manually
on:
  push:
    branches-ignore: main

jobs:
  parallel-test:
    runs-on: ${{ matrix.os }}
    strategy:
      # max-parallel: 2
      matrix:
        tests: ['test1', 'test2', 'test3']
        os: [macos-latest, ubuntu-latest, windows-latest]
    steps:
    - name: Matrix job ${{ matrix.tests }}
      run:  |
        echo "Running test: ${{ matrix.tests }}"
        date
        echo "Taking a quick nap..."
        sleep 15
        date
```

1. Open a pull request and merge the `dependent-job` branch into the `main` branch.
