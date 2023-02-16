# Create a `Dockerfile`

In this session, we are going to be deploying an application within a Docker
container. Before we can deploy our app, we need to set up the foundation for
our deployment pipeline. In this demo, we will use
[`myoung34/github-runner`](https://hub.docker.com/r/myoung34/github-runner) from
DockerHub as our base image, however you can replace this with any image of your
choosing.

1. Create a new branch named `docker`

   ```bash
   git checkout -b docker
   ```

2. In the root of the repository, create a new file named `Dockerfile` with the
   following contents

   > **:warning: NOTE:** Make sure to update `orgname` and `reponame` to your
   > organization and repository names.

   ```Dockerfile
   #################################
   ### Dockerfile to Run a Build ###
   #################################

   # This is a copy of the GitHub Action runner. You can replace this base
   # image with a base image of your choosing.
   FROM docker/github-actions:latest

   #############
   # Variables #
   #############
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

   ######################################
   # Copy dependency files to container #
   ######################################
   COPY dependencies/* /

   # ###############################
   # # Install Python dependencies #
   # ###############################
   # RUN pip3 install --no-cache-dir pipenv
   # # Bug in hadolint thinks pipenv is pip
   # # hadolint ignore=DL3042
   # RUN pipenv install --clear --system

   # ###################
   # # Run NPM Install #
   # ###################
   # RUN npm config set package-lock false \
   # && npm config set loglevel error \
   # && npm --no-cache install
   # # Add node packages to path
   # ENV PATH="/node_modules/.bin:${PATH}"

   # #############################
   # # Install Ruby dependencies #
   # #############################
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

3. Commit the file

   ```bash
   git commit -am 'Add Dockerfile'
   ```

4. Open a pull request and merge the `docker` branch into the `main` branch,
   making sure to delete the `docker` branch after doing so
