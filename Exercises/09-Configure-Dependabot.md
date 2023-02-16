# Configure Dependabot

In this lesson, we are going to integrate [Dependabot](https://dependabot.com/)
with GitHub Actions in your repository. Dependabot will help validate your code
is up to date and free of known security vulnerabilities.

## Enable Dependabot

1. Navigate to your repository on GitHub.com
2. Select the **Settings** tab
3. In the **Security** section, select **Code security and analysis**
4. Enable **Dependabot alerts**
5. Enable **Dependabot security updates**

## Add Dependabot Configuration

1. In your local repository, create a branch named `dependabot`

   ```bash
   git checkout -b dependabot
   ```

2. In the `.github/` directory, create a file named `dependabot.yml` with the
   following contents

   ```yaml
   ############################
   # GitHub Dependabot Config #
   ############################
   version: 2

   updates:
     # Maintain GitHub Actions Dependencies
     - package-ecosystem: github-actions
       directory: '/'
       schedule:
         interval: daily
       open-pull-requests-limit: 10

     # Maintain Docker Dependencies
     - package-ecosystem: 'docker'
       directory: '/'
       schedule:
         interval: 'daily'
       open-pull-requests-limit: 10

     # Maintain Python Dependencies
     - package-ecosystem: 'pip'
       directory: '/dependencies'
       schedule:
         interval: 'daily'
       open-pull-requests-limit: 10

     # Maintain Node.js Dependencies
     - package-ecosystem: 'npm'
       directory: '/dependencies'
       schedule:
         interval: 'daily'
       open-pull-requests-limit: 10

     # Maintain Ruby Dependencies
     - package-ecosystem: 'bundler'
       directory: '/dependencies'
       schedule:
         interval: 'daily'
       open-pull-requests-limit: 10
   ```

3. Commit the file

   ```bash
   git commit -am 'Add dependabot configuration'
   ```

4. Open a pull request and merge the `dependabot` branch into the `main` branch,
   making sure to delete the `dependabot` branch after doing so

## View Dependabot Alerts

Now that Dependabot is configured for your repository, it will scan the codebase
and open pull requests for any known security vulnerabilities. Several files are
included in this repository that will generate Dependabot alerts.

> **:warning: NOTE:** It may take some time for Dependabot to scan your
> repository and generate pull requests. Please be patient!

1. Navigate to the **Pull requests** tab of your repository
2. Select any open pull request with the `dependencies` label
3. Review the release notes and commit information for the dependency

Feel free to repeat this process for any other open Dependabot pull requests! In
the next exercise, we will lock our project dependencies to specific versions.
This will prevent Dependabot from opening pull requests for minor and patch
updates that are outside of the specified version ranges.

## Additional Links

- [Dependabot configuration](https://docs.github.com/en/code-security/dependabot/dependabot-version-updates/configuration-options-for-the-dependabot.yml-file)
