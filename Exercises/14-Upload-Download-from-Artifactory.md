# Upload and Download Artifacts from Artifactory

If your project produces build artifact(s) that are needed by other projects or
users, the
[`actions/upload-artifact`](https://github.com/actions/upload-artifact) and
[`actions/download-artifact`](https://github.com/actions/download-artifact)
actions can help with this process. If your team is using Artifactory, you can
also use the
[JFROG CLI Action](https://github.com/marketplace/actions/jfrog-cli) to connect
to Artifactory and run various CLI commands.

1. Create a branch named `artifactory`

   ```bash
   git checkout -b artifactory
   ```

1. Add the following code to your build pipeline, and it will then start
   publishing the artifact once the step has completed.

1. Create a new branch called `Artifacts`
1. Copy and paste the following code snippet into one of your working workflow
   files:

```yaml
# Upload an artifact to Artifactory
name: Upload to Artifactory
    uses: Deepakanandrao/jfrog-cli@v3
    with:
      cli_cmd: |                                      # commands to be excuted
      'jfrog rt u "(*).tgz" my-local-repo/{1}/ --recursive=false'
    env:
      SERVER_URL: ${{ secrets.SERVER_URL }}           # Required (e.g. https://jfrogy.com/artifactory)
      SERVER_ID: ${{ secrets.SERVER_ID }}             # Optional - Name to be recognized server with
      DISTRIBUTION_URL: ${{ secrets.SERVER_URL }}     # Optional
      ACCESS_TYPE: ${{ secrets.ACTION_TYPE }}         # Required  (username-password, access-token, api-key)
      USERNAME: ${{ secrets.USERNAME }}               # Required any of one of the following
      PASSWORD: ${{ secrets.PASSWORD }}
      API_KEY: ${{ secrets.API_KEY }}
      ACCESS_TOKEN: ${{ secrets.ACCESS_TOKEN }}

  # Download an artifact from Artifactory
  name: Download from Artifactory
      uses: Deepakanandrao/jfrog-cli@v3
      with:
        cli_cmd: |                                      # commands to be excuted
        'jfrog rt dl my-local-repo/cool-froggy.zip'
      env:
        SERVER_URL: ${{ secrets.SERVER_URL }}           # Required (e.g. https://jfrogy.com/artifactory)
        SERVER_ID: ${{ secrets.SERVER_ID }}             # Optional - Name to be recognized server with
        DISTRIBUTION_URL: ${{ secrets.SERVER_URL }}     # Optional
        ACCESS_TYPE: ${{ secrets.ACTION_TYPE }}         # Required  (username-password, access-token, api-key)
        USERNAME: ${{ secrets.USERNAME }}               # Required any of one of the following
        PASSWORD: ${{ secrets.PASSWORD }}
        API_KEY: ${{ secrets.API_KEY }}
        ACCESS_TOKEN: ${{ secrets.ACCESS_TOKEN }}
```

> **Note:** Please update the path to an artifact that was created in the build
> process.

### Linkage

- [JFrog CLI Action](https://github.com/marketplace/actions/jfrog-cli)
- [Action Repo](https://github.com/Deepakanandrao/jfrog-cli)
