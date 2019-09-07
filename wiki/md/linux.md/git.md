### Git
--------
1. ##### Config

    1. System settings: `/etc/gitconfig` 
    
            # git config --system

    2. Global settings: `~/.gitconfig`

            # git config --global

    3. Repository specific: `.git/config`

            # git config --local

2. ##### Aliases

    1. Make unstage a specific fileA:
    
            # git reset HEAD -- fileA   

    or via aliases:

            # git config --global alias.unstage 'reset HEAD --'

    2. Last commit:

            # git config --global alias.last 'log -1 HEAD'

    
>[!Link]
> 1. [Customizing Git - Git Configuration](https://git-scm.com/book/en/v2/Customizing-Git-Git-Configuration)
> 2. []()

2. ##### Status

3. ##### Stages

4. ##### Remote branches

    1. Remote branches are not movable and we can't edit it instead Git creates a local copy of remote branch: *origin/master* and *master* 
    
            origin/master # remote branch master

    2. If we had any changes locally and someone has made commits in the remote branch *master* then we decided to fetch the updates we ended up with our local version of *master* and remote version of *origin/master*:
    
        ![Remote and local branches](https://git-scm.com/figures/18333fig0324-tn.png "Remote and local branches")
    Also to fetch changes and update our origin/master branch as it is depicted on the picture: `git fetch origin`

    3. If we have several different servers then we have several distinguished reference to a project: each team working on a particular server will have a standalone branch to the project as on the img:
        
        ![Different team servers and one project](https://git-scm.com/figures/18333fig0325-tn.png "Different team servers and one project")

        To add a particular remote branch to our local version of the project: `git remote add teamone <url>` 

    4. To push our local working branch (`develop`) to the remote repository: `git push origin develop` so that it updates the remote branch *develop* or `git push origin develop:develop`, which does the same thing — it says, “Take my *develop* and make it the remote’s develop”.
    **Important**: When we do a fetch that brings down new remote branches, you don’t automatically have local, editable copies of them. In other words, in this case, you don’t have a new serverfix branch — you only have an *origin/develop* pointer that you can’t modify. To merge this work into your current working branch, you can run `git merge origin/serverfix`. If you want your own *develop* branch that you can work on, you can base it off your remote branch:

            $ git checkout -b serverfix origin/serverfix
            Branch serverfix set up to track remote branch serverfix from origin.
            Switched to a new branch 'serverfix'    

    5. To track a remote branch we need to checkout it from a remote rep: so that by default our local *master* branch is pointed to remote *origin/master*. Also we can redirect a local branch to track another remote branch: `git checkout -b [branch] [remotename]/[branch]`
    
    6. To delete a remote branch: `git push origin :develop`
    7. To clone a specific remote branch: `git clone --single-branch --branch <branchname> <remote-repo>`
    8. To show local branches and connected to them branches: `git remote show origin`
    9. To stash all the local changes: `git reset --hard`


5. ##### How to fetch a specific folder only?

What you want to do, is fetch the remote branch, and from that, extract the dir/file you need.

```
$ git fetch <remote> <branch>
$ git checkout <remote>/<branch> -- relative/path/to/file/or/dir
the file/dir should now be in your branch and added to the index.
```

6. ##### Git caveats

In an effort to fool you into thinking that it manages files’ permissions as well as their contents, Git shows you file modes when adding new files to the repository. It’s lying; Git does not track modes, owners, or modification times. But it tracks the executable bit.

>[!Links]
> 1. [Remote branches](https://git-scm.com/book/en/v1/Git-Branching-Remote-Branches)
> 2. [Basic](https://www.liquidlight.co.uk/blog/git-for-beginners-an-overview-and-basic-workflow/)

