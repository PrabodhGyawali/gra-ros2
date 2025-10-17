# Contributing to Gryphon Racing AI

This guide outlines the process for forking, developing, and submitting changes. It follows GitHub's best practices for open-source contributions. For more on GitHub's guidelines, see [GitHub Docs on Contributing](https://docs.github.com/en/communities/setting-up-your-project-for-healthy-contributions/setting-guidelines-for-repository-contributors).

## Prerequisites
- **Git Setup**: Ensure Git is installed and configured with your GitHub account (e.g., `git config --global user.name "Your Name"` and `git config --global user.email "your.email@example.com"`). For authentication, use SSH keys or a Personal Access Token (PAT) if using HTTPS.
- **Development Environment**: Follow the [Getting Started](/Getting-Started--New-Members) guide to set up Ubuntu 24.04, ROS 2 Jazzy, and clone the repo.

## Step 1. Fork the Repository
Forking creates a personal copy of the repo under your GitHub account, where you can experiment without affecting the main project.

1. Navigate to the [GryphonRacingAI/gra-ros2](https://github.com/GryphonRacingAI/gra-ros2) repo on GitHub.
2. Click the **Fork** button in the top-right corner.
3. Select your personal account or an organization (if permitted) as the owner.
4. Optionally, rename the fork or add a description (e.g., "My fork for SLAM improvements").
5. By default, only the default branch (`dev`) is copied—uncheck "Copy the DEFAULT branch only" if you need all branches.
6. Click **Create fork**.

Your fork is now at `https://github.com/YOUR-USERNAME/gra-ros2`. Clone it locally:
7. Add remote url to original repo to pull any changes 
```bash
git remote add upstream https://github.com/GryphonRacingAI/gra-ros2.git
git remote -v 
```

Fetch updates regularly: `git fetch upstream` then `git merge upstream/dev` (while on your local `dev` branch).

## Step 2: Create a Branch for Your Changes
Always work on a feature branch to keep `dev` clean.

1. Switch to the `dev` branch: `git checkout dev`
2. Update from upstream: `git pull upstream dev`
3. Create and switch to a new branch: `git checkout -b feature/your-descriptive-branch-name` (e.g., `feature/slam-cartographer-integration`).
4. Make your changes (edit code, add tests, update docs).

ROS 2-Specific Tips:
- Use `colcon build` after changes, and `ros2 test` for unit tests.
- Follow ROS style: [ROS 2 C++ Style Guide](https://docs.ros.org/en/jazzy/contributing/c-style-guide.html) for C++; PEP8 for Python.
- Commit often with clear messages: `git commit -m "Add Cartographer SLAM node with topic remapping"`.

## Step 3: Push and Create a Pull Request (PR)
1. Push your branch to your fork: `git push origin feature/your-branch-name`
2. On GitHub, navigate to your fork. You'll see a yellow banner: Click **Compare & pull request**.
3. On the PR creation page:
   - **Base repository/branch**: Select our repo (`GryphonRacingAI/gra-ros2`) and `dev` branch.
   - **Head repository/branch**: Auto-selected as your fork and branch.
   - Add a **title** (e.g., "Integrate Cartographer for SLAM module").
   - In the **description**, include:
     - What/Why: Link to related issues (e.g., "Fixes #42").
     - How to test: Steps to reproduce (e.g., "Run `ros2 launch slam_module cartographer.launch.py`").
     - Changes: Bullet points on files modified.
     - Screenshots/GIFs if visual (e.g., sim output).
4. If ready for review, click **Create pull request**. For work-in-progress, select **Create Draft Pull Request**.

Allow edits from maintainers? Check the box to let us help refine your PR.

## Best Practices and Checklists
Follow these to ensure smooth reviews:

### Before Submitting
- [ ] Runs `colcon build --packages-select your_package` without errors.
- [ ] All tests pass: `colcon test --packages-select your_package`.
- [ ] No secrets/credentials committed.

### After merging
- [ ] Docs updated if requested by subteam leader (e.g., module wiki pages).

### PR Guidelines
- **Descriptive Title**: Start with action verb (e.g., "Add", "Fix", "Update").
- **Linked Issues**: Use "Closes #issue" or "Related to #issue".
- **Small & Focused**: One PR per feature/bug; break large changes into multiple PRs.
- **Request Reviewers**: @ specific team members (e.g., SLAM lead).
- **Respond to Feedback**: Address comments promptly; push follow-up commits.

## Common Workflows
- **Bug Fix**: Branch from `dev`, fix, PR to `dev`.
- **New Feature**: Same, but link to feature issue.
- **Docs Only**: Branch from `dev`, edit Markdown, PR.

If your PR is merged you can delete the branch on GitHub for tidiness. We aim for quick reviews—expect feedback within 2-3 days.

**Questions?** Message your subteam leader.

*Last updated: October 15, 2025*