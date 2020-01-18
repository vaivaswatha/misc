# A Handy Git Reference

## Prerequisites

  * Install git:
    - `$sudo apt-get install git`
  * Basic configuration. This step can be skipped. The third command is to tell
  git to use your favorite editor for editing commit messages.
    - `$git config --global user.name "Vaivaswatha N"`
    - `$git config --global user.email "vaivaswatha@donotemailme.in"`
    - `$git config --global core.editor emacs`
  * `cd` into the directory you want to establish as a git repository

## Creating a git repository

  * Create a new git repo for this directory.
    - `$git init`
  * Mark all files in the directory for committing (note the trailing `.`).
    - `$git add .`
  * Commit all these files to the repo. This step completes the repo setup.
  `git` will prompt you to enter a commit message. Just say something like
  "creating new repo", save the file and exit.
    - ` git commit`
  * Your git repo is now ready. All your files are under version control.

## Cloning an existing repository

If you want to work on an existing git repository (say from GitHub),
you will need to clone it to have a copy locally.
  - `git clone https://github.com/vaivaswatha/misc.git misc` will clone *this*
  repository  into a directory called `misc`.
  - You can make clone of repositories already on your disk or remote
  repositories over SSH. Just replace the URL above with a path name or an ssh
  string respectively.

## Basic version control using git

  * To check currently modified files in your repo, run this command in any
  (sub)directory of your repo.
    - `$git status`
  * Mark modified files for commit: This command will add files to the
  [staging area](http://git-scm.com/book/en/Git-Basics-Recording-Changes-to-the-Repository#Staging-Modified-Files),
  which means its marked for commit, and will be committed the next time you run
  `git commit`. If you make any changes to files after `add`ing them, those
  changes will not make it to the commit, you will need to again `add` the file.
    - `$git add <filename(s)>`
  * Commit files: This will commit marked files to the repo. After this, these
  files will no longer be shown under "git status" command. You will need to
  enter a commit message. You can append `-m "commit message"` to the command
  instead of having to open an editor and enter the message there.
    - `$git commit`
  * Undo changes to uncommitted files. This will reset the files to the last
  committed version. This will work if you have not already `add`ed the files to
  the staging area.
    - `$git checkout <filename(s)>`
  * Unstage from staging area.
    - `git reset <filename(s)>`
  * Log: see commit logs for your repo
    - `$git log`
  * Revert a commit: This will try to undo all changes done by a commit.
  The revert itself will be a new commit.
    - `$git revert SHA1`
  * Diff: See the local changes to file(s). You can also provide two commit
  hashes (show in `git log`) to see the diff b/w them. Branchnames can be
  provided as an argument to see diff of current working directory comparing to
  a branch.
    - `$git diff <filename(s)>`
    - `$git diff SHA1 SHA2`
    - `$git diff master` (compare working directory with branch `master`)
  * Show the details of a particular commit, including the code diff.
    - `$git show SHA1`
  * Checkout old versions: This command will checkout an older version into a new branch. Here SHA1 is the hash of the older revision you want to check out (this can be obtained from `git log`).
    - `$git checkout -b <NewBranchName> SHA1`
  * Switch branches. You need to have all files committed before you can switch branches.
    - `$git checkout <BranchName>`
  * See all branches present:
    - `$git branch`
  * Delete a branch:
    - `$git branch -D <BranchName>`
  * Merge branches: This command will merge `BranchName` to the currently active
   (selected) branch.
    - `$git merge <BranchName>`
  * Rebase against `master`: This command will update the current branch with
  changes from master. i.e. After you branched out, master might have moved
  forward. Rebasing your branch with master will get your branch up to date with
  master. Note that rebasing works by replaying all commits since the point of
  divergence. See next.
    - `$git rebase master`
  * Typical workflow is to branch out (say `branch1`) from master, do your work
  in `branch1` and commit it. Then switch to master and merge `branch1` to it
  (typically by having it reviewed / creating a pull-request). Changes from
  different branches come into master this way (via merges). Your branch can
  keep updated with `master` by merging `master` to your branch, OR
  alternatively, by `rebase`ing against it. Note that rebasing will cause all
  commits since divergence from `master` to be re-committed. This will create a mess
  if your local branch is tracking a remote branch and you push to the remote
  branch. Use `git merge` to merge from `master`, instead. Some teams do
  not however recommend merging `master` to your branch (but ask you to rebase instead)
  because merging creates what is called a merge commit.
  * Cherry pick (merge a specific commit) from another branch, instead of merging all of it.
    - `$git cherry-pick SHA1`
  * See this [link](http://git-scm.com/book/en/Git-Branching-Basic-Branching-and-Merging)
  for more details on branching in git.
  * Stashing and getting back local working changes (i.e, those changes in the
  working area - not yet committed). The first one stashes away the code and
  restore the codebase to HEAD (last committed change). The second one will
  restore back the changes.
    - `$git stash`
    - `$git stash pop`
    - `$git stash list`
  * Adding a `remote` to an existing git repository: (If adding a second remote,
  give it a name other than `origin`). `origin` is conventionally where you cloned
  your repository from.
    - `$git remote add origin path://to/git/repo `
  * Checking out and updating branches (not necessarily `master`) from remote:
    - `$git remote update`
    - `$git checkout -b branchname origin/branchname`
  * Push changes up-stream (you can omit the last two arguments
  if you are on "master"). The `-u` argument ensures that from next time,
  you can do an argument less `pull` or `push` on that branch to correspond with
  `origin`.
    - `$git push -u origin branchname`
  * Pull changes from a repository other than "origin" (repository needs to be
  added using "git remote add" command).
    - `$git pull repo branchname`
  * Modify the last commit. Any changes you want to make, like including adding
  new files from the staged area to the commit or editing the commit message,
 can be done with this command:
    - `$git commit --amend`
  * Pretty print (branch graph etc) git log. Use command "git lg" after running
  this command
    - `$git config --global alias.lg "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n''          %C(white)%s%C(reset) %C(dim white)- %an%C(reset)' --all"`
