# Create and Use a GitHub Package

This exercise will walk you through the steps to create and use a package with
GitHub Packages. GitHub Packages supports a number of different package types,
and has separate registries for each.

| Language   | Package format     | Package client |
| ---------- | ------------------ | -------------- |
| JavaScript | `package.json`     | `npm`          |
| Ruby       | `Gemfile`          | `gem`          |
| Java       | `pom.xml`          | `mvn`          |
|            | `build.gradle`     | `gradle`       |
|            | `build.gradle.kts` | `gradle`       |
| .NET       | `nupkg`            | `dotnet`       |
| Docker     | `Dockerfile`       | `docker`       |

In this exercise, we will be using Ruby, so we will create a `.gemspec` file and
pushing a new Gem to the GitHub Packages registry.

1. Create a branch named `packages`

   ```bash
   git checkout -b packages
   ```

2. In the `.github/workflows/` directory, create a file named `package.yml` and
   with the following contents

   ```yaml
   name: GitHub Package Registry

   on:
     # Start the job on push
     push:
       # Don't run on push to main
       branches-ignore:
         - 'main'

   jobs:
     # Build a Ruby gem
     build-gem:
       # Name the Job
       name: Build Ruby Gem

       # Set the platform to run on
       runs-on: ubuntu-latest

       # Define the steps
       steps:
         # Checkout the codebase
         - name: Checkout
           uses: actions/checkout@v3

         # Update the .gemspec file with the Gem name and version
         - name: Update .gemspec
           run: |
             sed -i "s/\[\[GEM_NAME\]\]/${{ github.event.repository.name }}/g" hello_world.gemspec
             sed -i "s/\[\[GEM_VERSION\]\]/${{ github.run_id }}/g" hello_world.gemspec
             cat hello_world.gemspec

         # Build the Gem
         - name: Build Gem
           run: gem build hello_world.gemspec

         # Authenticate to the GitHub Packages registry
         - name: Authenticate to GitHub Packages Registry
           run: |
             mkdir ~/.gem
             touch ~/.gem/credentials
             chmod 0600 ~/.gem/credentials
             echo ":github: Bearer ${{ secrets.GITHUB_TOKEN }}" >> ~/.gem/credentials
             gem push --key github --host https://rubygems.pkg.github.com/${{ github.event.repository.owner }} ${{ github.event.repository.name }}-0.0.${{ github.run_id }}.gem
   ```

3. Commit the file

   ```bash
   git add .
   git commit -m 'Add RubyGem package workflow'
   ```

4. Open a pull request and merge the `packages` branch into the `main` branch,
   making sure to delete the `packages` branch after doing so

   In the pull request, you will see the _GitHub Package Registry / Build Ruby
   Gem_ job running and the results when it completes.

   Once it completes, the _Continuous Integration / Download from Artifactory_
   job will start. You can review the logs of the run and the steps it took by
   selecting **Details** next to the action. You can experiment with this action
   by making additional updates to the code and committing it.

## Reference

- [Create your own gem](https://guides.rubygems.org/make-your-own-gem/)
- [Working with the RubyGems registry](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-rubygems-registry)
