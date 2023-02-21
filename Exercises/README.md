# :pencil2: Exercises

The goal of these exercises is to create a Continuous Integration/Continuous
Testing/Continuous Deployment (CI/CT/CD) workflow using Docker-based GitHub
Actions.

The numbered exercises walk through creating a basic CI action and iteratively
build a complex, thorough workflow.

## Repository Structure 🏗️

Before you go through these exercises, please be aware of the existing file
contents and structures in this repository.

| Directory       | Description                                                                                                                |
| --------------- | -------------------------------------------------------------------------------------------------------------------------- |
| `Exercises/`    | The list of exercises you will complete                                                                                    |
| `dependencies/` | The files that can be enabled from your `Dockerfile` to install dependencies for different runtimes                        |
|                 | You will create this `Dockerfile` in the first exercise                                                                    |
| `library/`      | Contains a sample [`entrypoint.sh`](../library/entrypoint.sh) that is called from your `Dockerfile` to run the application |

## Exercises

### Task 1: Create a Continuous Integration (CI) Workflow

- [Step 1: Create a `Dockerfile`](./01-Create-Dockerfile.md)
- [Step 2: Create a CI Action](./02-Create-CI-Action.md)

### Task 2: Add Complexity to the Workflow

- [Step 3: Create a Protected Branches](./03-Create-Protected-Branches.md)
- [Step 4: Create a Context Job](./04-Create-Context-Job.md)
- [Step 5: Create a Manual Job](./05-Create-Manual-Job.md)
- [Step 6: Create a Dependent Job](./06-Create-Dependent-Job.md)
- [Step 7: Create a Matrix Job](./07-Create-Matrix-Job.md)
- [Step 8: Create a Reusable Action](./08-Create-Reusable-Action)

### Task 3: Dependency Management

- [Step 9: Configure Dependabot](./09-Configure-Dependabot.md)
- [Step 10: Lock Your Dependencies](./10-Lock-Dependencies.md)

### Task 4: Continuous Testing (CT)

- [Step 11: Create a Continuous Testing (CT) Action](./11-Create-CT-Action.md)

### Task 5: Security Scaning

- [Step 12: Add Security Scaning](./12-Add-Security-Scaning.md)

### Task 6: Artifact Management

- [Step 13: Upload and Download Build Artifacts](./13-Upload-Download-Artifacts.md)
- [Step 14: Upload and Download from Artifactory](./14-Upload-Download-from-Artifactory.md)
- [Step 15: Create and Use a GitHub Package](./15-Create-GitHub-Package.md)

### Task 7: Continuous Deployment (CD)

- [Step 16: Deploy a Docker Image](./17-Deploy-Docker.md)
- [Step 17: Deploy a Release](./18-Deploy-Release.md)

### (Optional) Using GitHub Actions Beyond CI/CT/CD

- [Step 18: Use GitHub Script to Create Issues](./19-Create-Issues.md)
- [Step 19: Use GitHub's Deployment API to Update Environments](./20-Deployment-API.md)
- [Step 20: (**Advanced**) Add Dependencies Between Jobs](./21-Wait-for-Jobs.md)
- [Step 21: (**Advanced**) Split Jobs for Faster Workflows](./22-Split-Jobs.md)
- [Step 22: (**Advanced**) Reuse a Local Action](./23-Reuse-Local-Action.md)

## :book: Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
