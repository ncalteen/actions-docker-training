# Create Continuous Delivery / Continuous Deployment Actions

Continuous Delivery / Continuous Deployment (CI/CD) can reduce the challenge of
getting your finished code or product into the hands of your end users.
Automating processes such as building, testing, and deploying your code reduces
the risk of human error and enables faster delivery or deployment.

Two of the main factors to consider when designing a CI/CD workflow are _what
you are building_ and _how often you are building it_.

- If releases only happen every quarter, fully automating the release process
  may require more effort than it is worth. However, a solid, documented
  workflow will still help the process.
- If you are deploying more often, a consistent, automated workflow driven by
  developer events will help you deliver faster and with less risk.

The examples we have will help solve most of the use cases.

## Split Jobs for Faster Workflows

As you can see, some steps take much time, and others are fairly quick. As you
progress though your knowledge of **GitHub Actions**, you should be able to
split up jobs and steps, and set up advanced wait conditions to help speed up
your pipelines.

By doing so, you make sure you get reliable, and instant feedback from your
build process.
