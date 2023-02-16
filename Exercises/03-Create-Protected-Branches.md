# Create Protected Branches

Many organizations follow different development models, such as
[GitHub flow](https://docs.github.com/en/get-started/quickstart/github-flow) or
[Git flow](https://nvie.com/posts/a-successful-git-branching-model/). One
primary difference between these two approaches is Git flow uses multiple
long-lived branches that represent different stages of maturity. For example,
the following branch conventions are commonly used:

- The `develop` branch represents changes that are being prepared for delivery
  in the next release
- The `release` branch represents the production-ready state of the project

![gitflow](https://user-images.githubusercontent.com/38323656/102368103-1c69ed80-3f80-11eb-9353-586432ec0678.png)

> An example workflow which adopts the Git flow strategy

If you plan to use Git flow, you will likely need to create several long-lived
branches.
[Branch protection](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/defining-the-mergeability-of-pull-requests/about-protected-branches)
is an important feature that allows you to control who can push to a branch and
when. For example, you can require that pull requests be approved by a certain
number of people before they can be merged into a branch. You can also require
that status checks pass before a branch can be merged into another branch. In
Git flow, you can use branch protection to ensure:

- Merging into `develop` or `release` must be done through a pull request
- Merging into `develop` requires all status checks to pass
- Merging into `release` requires all status checks to pass **and** at least one
  review

> **NOTE:** For the sake of brevity, we won't use Git flow in this training.

1. Create a new branch called `release` and push it to GitHub.com

   ```bash
   git checkout -b release
   git push -u origin release
   ```

2. Create a new branch called `develop` and push it to GitHub.com

   ```bash
   git checkout -b develop
   git push -u origin develop
   ```

3. On [GitHub.com](https://github.com), navigate to the main page of your
   repository
4. Select **Settings**
5. Under **Code and automation**, select **Branches**
6. Select **Add branch protection rule**
7. In the **Branch name pattern** text field, enter `develop`
8. In the **Protect matching branches** section, select **Require a pull request
   before merging**, and deselect **Require approvals**
9. Select **Require status checks to pass before merging**, then search for the
   `ci` action you created previously
10. Select **Create**
11. Select **Add rule**
12. In the **Branch name pattern** text field, enter `release`
13. In the **Protect matching branches** section, select **Require a pull
    request before merging**
14. Select **Require status checks to pass before merging**, then search for the
    `ci` action you created previously
