# Creating a package in the GitHub Package registry and using it

- If you want to publish and use the GitHub Package Registry, this is a simple example of how to do it.

### Exercise: Add Upload and Download

1. Add the following code to your build pipeline, and it will then start publishing the artifact once the step has completed.

1. Create a new branch called `Packages`
1. Copy and paste the following code snippet into one of your working workflow files:
```yaml
---
    ##############################
    ##############################
    ## Publish ruby gem and use ##
    ##############################
    ##############################
    name: GitHub Package Registry

    #
    # Documentation:
    # https://help.github.com/en/articles/workflow-syntax-for-github-actions
    #

    #############################
    # Start the job on all push #
    #############################
    # Don't need to run on push to master/main
    on:
      push:
        branches-ignore:
          - 'master'
          - 'main'

    ###############
    # Set the Job #
    ###############
    jobs:
      build-gem:
        # Name the Job
        name: Build Ruby Gem
        # Set the agent to run on
        runs-on: ubuntu-latest
        ##################
        # Load all steps #
        ##################
        steps:
          ##########################
          # Checkout the code base #
          ##########################
          - name: Checkout Code
            uses: actions/checkout@v2

          ######################
          # Build the Ruby Gem #
          ######################
          - name: Adjust gemspec
            run: |
              sed -i "s/\[\[GEM_NAME\]\]/${{ github.event.repository.name }}/g" hello_world.gemspec
              sed -i "s/\[\[GEM_VERSION\]\]/${{ github.run_id }}/g" hello_world.gemspec
              cat hello_world.gemspec

          ######################
          # Build the Ruby Gem #
          ######################
          - name: Build gem
            run: gem build hello_world.gemspec
          
          ###########################################
          # Authenticate to github package registry test #
          ###########################################
          - name: Authenticate to GitHub Package Registry
            run: |
              mkdir ~/.gem
              touch ~/.gem/credentials
              chmod 0600 ~/.gem/credentials
              echo ":github: Bearer ${{ secrets.GITHUB_TOKEN }}" >> ~/.gem/credentials
              gem push --key github --host https://rubygems.pkg.github.com/${{ github.repository_owner }} ${{ github.event.repository.name }}-0.0.${{ github.run_id }}.gem

```

### Linkage
- [Create your own gem](https://guides.rubygems.org/make-your-own-gem/)
- [Create and deploy gem](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-rubygems-registry)
