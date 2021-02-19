---
title: "Git survival kit"
date: 2020-07-07
hero: /images/posts/git.png
categories:
- Development
- writing-posts-category
---


When I first started in my current company I hadn't used any version control system so when I started using Git it was a little tricky. Lucky me I had one of the best developers I've ever worked with, [Víctor Guzmán](https://github.com/vguzmanp). I remember he said something like: "Ok, you can use a GUI for a bad Git usage or you can use the Terminal for learning real Git usage. I use Terminal so I won't help you with if you don't use it". Since that day he turned me on a Terminal paladin and five years later I have not used a Git GUI tool for nothing (well, except `gitk`... and [GitKraken](https://www.gitkraken.com/) I used once for a very big mess with a rebase conflict).

Here are some Git commands I use in my every day developer life:

---
#### Git setup:

> `git config --global --edit` ->> Edit the Git user we are going to work with.

> `git commit --amend --reset-author` ->> Reset the author we have just edited to work with.

<br />

#### Basic Git commands:

> `git status` ->> Info about the current repository status (you have to stay inside a path initialized as a Git repository).

> `git diff` ->> Shows the differences with the previous commited changes.

> `git diff -w` ->> Shows the differences with the previous commited changes ignoring changes related to whitespaces.

> `git checkout .` ->> Deleted all uncommited changes starting in the current path.

> `git checkout <PATH>` ->> Delete uncommited changes of the specified path.

> `git checkout -p` ->> Shows change by change giving the option to decline them or not. 

> `git add <PATH>` ->> Accept changes done in the specified path.
  
> `git add -A` ->> Accept all changes without reviewing them.
  
> `git add -p` ->> Shows change by change giving the option to accept them or not. 

<br />

#### Git branching commands:

> `git branch` ->> Lists all local branches.

> `git branch <BRANCH_NAME>` ->> Creates a branch with the specified name.

> `git checkout <BRANCH_NAME>` ->> Change current branch to the existing one with the specified name.

> `git checkout -b <BRANCH_NAME>` ->> Creates a branch with the specified name and changes the current branch to it.

> `git branch -D <BRANCH_NAME>` ->> Deletes the specified local existing branch with the specified name.

> `git push origin --delete <BRANCH_NAME>` ->> Deletes the specified remote existing branch with the specified name.

> `git rebase <BRANCH_NAME>` ->> puts your actual branch at the level of the specified branch and puts your commits that are not in there at the top level. This can cause conflicts.

> `git cherry <BRANCH_NAME> -v` ->> Shows the commits from the current branch that the specified one does not have witn the `+` symbol and shows the ones that already have with the `-` symbol.

<br />

#### Getting/Pushing recent changes:

> `git pull` ->> Gets the repository changes of all branches and applies the new changes of the current branch on it.

> `git fetch` ->> Gets the repository changes of all branches but it does not apply them anywhere. Just gets the information.

> `git push origin <BRANCH_NAME>` ->> Pushes the current branch commits to the specified branch in the repository.

> `git push origin <BRANCH_NAME> -f` ->> Forces a push of the current branch status to the repository. All changes in the repository that we do not have will be overriden.

<br />

#### Git commits and logs:
  
> `git commit` ->> Creates a commit with the current accepted changes. This will prompt the user with an editor to ask for a commit message.

> `git commit -m '<COMMIT_MESSAGE>'` ->> Creates a commit with the current accepted changes. The commit will have the specified commit message.

> `git show` ->> Shows the last commit changes.

> `git show <COMMIT_HASH>` ->> Shows the specified commit changes.

> `git log` ->> Shows all commits of the current branch. This command will provide you the hash of each commit.

> `git log -L48,50:<FILE_PATH>` ->> Shows all commits related to the specified having changes between line 48 and 50.

> `git log <COMMIT_HASH> -L76,76:<FILE_PATH>` ->> Shows all commits related to the specified having changes at line 76 starting at the specified commit hash.

> `git cherry-pick <COMMIT_HASH>` ->> Copy the specified commit from another branch into the current branch.

<br />

#### Different situations and how to face them:
<br />

##### I have done a rebase against another branch and now I have conflicts:

* `git status` ->> To see the files where I have conflicts.
* Open each file and look for the conflicts in there. Look for something like “<<<<“ where you can see your changes and the changes in the other branch that are causing conflicts.
* `git add <PATH>` ->> Add the files you have just solved the conflicts in.
* `git rebase --continue` ->> To continue the rebase process once all current conflicts are solved.

<br />

##### I have PUSHED a commit in a branch but I want to revert it:

There are two ways for solving this situation:

> Can be someone else working on that branch (i.e.: master, release, etc.)?
>> * `git checkout <BRANCH_NAME>` ->> Place yourself in the desired branch.
>> * `git pull` ->> Get last changes in the repo.
>> * `git log origin/<BRANCH_NAME>` ->> To show the log you are looking for. Copy the desired commit hash code.
>> * `git revert <COMMIT_HASH>` ->> This creates a commit reverting the specified commit.
>> * `git push origin <BRANCH_NAME>` ->> Push the new commit to the repo.

> Are you the only one that is working on that branch?
>> * `git checkout <BRANCH_NAME>` ->> Place yourself in the desired branch.
>> * `git pull` ->> Get last changes in the repo.
>> * `git reset --hard HEAD~1`->> This will remove the last commit but will mantain its changes as uncommited (assuming the last commit is the one you want to remove).
>> * Now do whatever you need with these changes.

<br />

##### I have done recent changes that can fit in my previous commit:

Instead of `git reset HEAD~1` and commit again, you can do something easier:

> * `git add -p` ->> Add the new changes.
> * `git commit --amend` ->> Commit those changes in the previous commit. If you have already pushed this commit you will need to force a push (but keep in mind the previous situation!).

<br />

##### Save uncommited changes for later:

If you need to perform any action that you can not do because you have "uncommited changes" you can save them for later as a CUT/PASTE in the clipboard of your computer.

> `git stash` ->> All uncommited changes are saved for later. (CUT)

> `git stash pop` ->> All saved changes are delivered to the current branch as uncommited changes again. (PASTE)

<br />

##### I have done a very big commit that I want to split in different commits:

> * `git reset HEAD~1` ->> Undo the last commit.
> * `git add -p` ->> Add desired changes.
> * `git commit` ->> Commit the desired changes.

* Repeat the add + commit process as times as needed.

<br />

##### I have to apply changes on a pull request someone else has reviewed:

When you are applying requested changes on a pull request you will need to create new commits to make it easier to review for your reviewer. For that, follow this:

> * Add changes related to a commit.
> * `git log` ->> To get the hash commit of the related one.
> * `git commit --fixup <COMMIT_HASH>` ->> This will create a fixup commit.

Repeat the process for each commit to be fixed. Once reviewed you won't fixup commits on the destination branch so you will need to to the next:

> * `git rebase -i HEAD~n` ->> Where 'n' is the number of commits to work with.
> * In my case VIM editor is opened and it puts the fixup commits in the proper place. But if not you just need to put each fixup commit just after the original commit.
> * `git push -f` ->> Force a push to your branch in the repo.

i.e.: Imagine you have 2 commits:

> pick d747d49f2 Print Hello world.<br />
> pick 6f39ac83b Close app when pressing ESC key.

Then your reviewer ask to not print "Hello world" but "Good morning Vietnam!", so you create a fixup commit as described. Then 'n' in the interactive rebase should be 3 because we whant to rebase 3 commits (`git rebase -i HEAD~3`) and it should look like this:

> pick d747d49f2 Print Hello world.<br />
> fixup pick 6g84etd6e fixup! Print Hello world.<br />
> pick 6f39ac83b Close app when pressing ESC key.

Save the edition and the rebase will be produced. Also in this case since the message is no more "Hello World" we would like to rename the commit message, so in the interactive rebase we also could have changed the word `pick` by the letter `r` for `r`ename the message:

> r d747d49f2 Print Hello world.<br />

Once saved the edition the terminal will prompt with a new editor to edit the commit message. Save it and the rebase process will be the same as described before but changing the desired commit message!

---
---
<br />

I hope you can find something useful in these Git commands. I have more commands and situations like working with submodules but I think that all this information I have provided should be enough to work with Git normally. Please don't hesitate to comment anything in the comment section if you need something else.

See you all in the next post!