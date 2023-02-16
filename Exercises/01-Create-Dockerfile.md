# Create the dockerfile

In this session, we are going to be deploying an application within a Docker
container. Before we can deploy our app, we need to set up the foundation for
our deployment pipeline. In this demo, we will use
[`docker/github-actions`](https://hub.docker.com/r/docker/github-actions) from
DockerHub as our base image, however you can replace this with any image of your
choosing.

## Step 1: Create a `Dockerfile`

1. Create a new branch named `Docker`

   ```bash
   git checkout -b Docker
   ```

2. In the root of the repository, create a new file named: `Dockerfile`
3. Copy and paste the following code snippet into the new file:

   > **:warning: NOTE:** Update the **orgname** and **reponame** variables to
   > your organization and repository names.

   ```Dockerfile
   #########################################
   #########################################
   ### Dockerfile to run some Some Build ###
   #########################################
   #########################################

   # This is a copy of the GitHub Action runner. You can replace this base image with other base image.
   FROM myoung34/github-runner:latest

   #########################################
   # Variables #
   #########################################
   ARG orgname="organization name"
   ARG reponame="repository name"

   #########################################
   # Label the instance and set maintainer #
   #########################################
   LABEL com.github.actions.name="Some Image" \
         com.github.actions.description="Its a build image" \
         com.github.actions.icon="code" \
         com.github.actions.color="red" \
         maintainer="GitHub DevOps <github_devops@github.com>" \
         org.opencontainers.image.authors="GitHub DevOps <github_devops@github.com>" \
         org.opencontainers.image.url="https://github.com/${orgname}/${reponame}" \
         org.opencontainers.image.source="https://github.com/${orgname}/${reponame}" \
         org.opencontainers.image.documentation="https://github.com/${orgname}/${reponame}" \
         org.opencontainers.image.vendor="GitHub" \
         org.opencontainers.image.description="Its a build image"

   ########################################
   # Copy dependencies files to container #
   ########################################
   COPY dependencies/* /

   # ################################
   # # Installs python dependencies #
   # ################################
   # RUN pip3 install --no-cache-dir pipenv
   # # Bug in hadolint thinks pipenv is pip
   # # hadolint ignore=DL3042
   # RUN pipenv install --clear --system

   # ####################
   # # Run NPM Installs #
   # ####################
   # RUN npm config set package-lock false \
   # && npm config set loglevel error \
   # && npm --no-cache install
   # # Add node packages to path
   # ENV PATH="/node_modules/.bin:${PATH}"

   # ##############################
   # # Installs ruby dependencies #
   # ##############################
   # RUN bundle install

   ######################
   # Make the directory #
   ######################
   RUN mkdir -p /action/lib

   #############################
   # Copy scripts to container #
   #############################
   COPY library /action/lib

   ######################
   # Set the entrypoint #
   ######################
   ENTRYPOINT ["/action/lib/entrypoint.sh"]
   ```

4. Commit the file.
5. Open a pull request and merge the `Docker` branch into the `main` branch.

# CLEAN UP: Delete the Docker branch file

We want to delete the branch **Docker** after we merged with the change.
Otherwise, **GitHub Actions** pipeline will trigger for all the branch changes
we have later. Make sure to delete the branch **Docker** branch once you merged
this branch to the **main** branch.
