---
name: git-expert
description: Comprehensive Git expertise for version control workflows, branching strategies, conflict resolution, and best practices. Use when performing Git operations, resolving merge conflicts, managing branches, reviewing history, or setting up workflows. Covers commands, reflog rescue, bisecting, rebase vs merge, and safety patterns.
---

# Git Expert

## Overview

Git is powerful but unforgiving. Wrong commands destroy work; right patterns save time.

**Core principle:** Git operations should be reversible, traceable, and intentional.

**Violating the letter of these patterns is violating the spirit of safe version control.**

## The Iron Law

```
NEVER RUN DESTRUCTIVE COMMANDS WITHOUT VERIFICATION
```

Before any `--force`, `reset --hard`, or `rebase`:
1. Verify current state with `git status`
2. Confirm branch with `git branch --show-current`
3. Check for uncommitted work
4. Have a reflog escape plan

## When to Use This Skill

Use for ANY Git operation:
- Branch creation and management
- Merging, rebasing, cherry-picking
- Conflict resolution
- History manipulation
- Undoing mistakes
- Inspecting history
- Remote synchronization

**Use this ESPECIALLY when:**
- About to force push
- Recovering lost work
- Resolving complex conflicts
- Rewriting public history
- You're unsure about the command

## Command Decision Tree

```
TASK: Starting new work
  → Read [Work Isolation](#work-isolation)
  → Create branch: git checkout -b feature/name OR git switch -c feature/name

TASK: Saving current work
  → Read [Saving Work](#saving-work)
  → commit -m "message" for ready work
  → stash push -m "message" for WIP

TASK: Integrating changes
  → Read [Merge vs Rebase](#merge-vs-rebase)
  → merge for: shared branches, preserving history
  → rebase for: cleaning local branches before merge

TASK: Undoing mistakes
  → Read [Undo & Recovery](#undo--recovery)
  → reflog for: lost commits, hard resets
  → revert for: public commits, shared branches
  → reset for: local commits only

TASK: Resolving conflicts
  → Read [Conflict Resolution](#conflict-resolution)
  → NEVER: git checkout --theirsOURS, edit files, run tests, commit
  → After resolution: verify with git status

TASK: Cleaning up
  → Read [Branch Hygiene](#branch-hygiene)
  → branch -d for: merged branches
  → branch -D for: unmerged branches (be careful)

TASK: Investigating bugs
  → Read [History Investigation](#history-investigation)
  → bisect for: finding when bug was introduced
  → blame for: finding who changed a line
  → log for: commit history and patterns
```

## Work Isolation

**Always work on a branch. Never commit directly to main/master.**

```bash
# Create new branch (modern)
git switch -c feature/awesome-thing

# Create new branch (classic)
git checkout -b feature/awesome-thing

# Create from specific starting point
git switch -c feature/awesome-thing origin/main
git switch -c feature/awesome-thing~5  # 5 commits back
```

**Branch naming conventions:**
- `feature/` - New features
- `bugfix/` - Bug fixes
- `hotfix/` - Urgent production fixes
- `refactor/` - Code refactoring
- `docs/` - Documentation changes
- `test/` - Test additions or changes
- `chore/` - Maintenance tasks

## Saving Work

### Committing (Ready Work)

```bash
# Stage specific files
git add path/to/file

# Stage all changes (tracked files)
git add -u

# Stage all changes including new files
git add -A

# Interactive staging
git add -i

# Commit with message
git commit -m "feat: add authentication flow"

# Commit with message including body
git commit -m "feat: add authentication flow

- Implement OAuth2 login
- Add session management
- Update error handling"

# Amend last commit (local only!)
git commit --amend

# Amend last commit without editing message
git commit --amend --no-edit
```

**Commit message conventions (Conventional Commits):**
```
<type>: <description>

[optional body]

[optional footer]
```

**Types:** feat, fix, docs, style, refactor, test, chore, perf, ci, build, revert

### Stashing (WIP / Unfinished Work)

```bash
# Stash with message
git stash push -m "work in progress: authentication"

# Stash including untracked files
git stash push -u -m "including new files"

# Stash specific files
git stash push path/to/file -m "file-specific stash"

# List stashes
git stash list

# Apply most recent stash (keeps in list)
git stash apply

# Apply specific stash
git stash apply stash@{2}

# Drop most recent stash
git stash drop

# Pop most recent stash (removes from list)
git stash pop

# Clear all stashes
git stash clear
```

## Merge vs Rebase

### Merge (Preserve History)

```bash
# Merge branch into current
git merge feature/awesome-thing

# Create merge commit even when fast-forward possible
git merge --no-ff feature/awesome-thing

# Squash merge (one commit)
git merge --squash feature/awesome-thing
git commit -m "feat: merge feature branch"
```

**Use merge when:**
- Working on shared branches
- History should be preserved
- Multiple people contribute to the branch
- You want to see when merges happened

### Rebase (Clean History)

```bash
# Rebase current branch onto main
git rebase main

# Rebase with autosquash (group fixup! commits)
git rebase -i --autosquash main

# Interactive rebase (last 5 commits)
git rebase -i HEAD~5

# Continue rebase after resolving conflicts
git rebase --continue

# Skip commit during rebase
git rebase --skip

# Abort rebase (return to original state)
git rebase --abort
```

**Use rebase when:**
- Cleaning local branch before merging
- Linear history is desired
- Squashing related commits
- Commits are not yet shared

**NEVER rebase:**
- Public/shared branches
- Commits others have based work on
- Force push to shared branches without coordination

## Undo & Recovery

### Reflog (The Escape Hatch)

```bash
# Show reflog (all movements)
git reflog

# Show reflog for specific branch
git reflog show main

# Recover lost commit
git reset --hard HEAD@{5}

# Recover from hard reset gone wrong
git reset --hard "commit@{1 hour ago}"

# Checkout previous state without moving HEAD
git checkout HEAD@{3}
```

**Reflog saves you when:**
- Hard reset went too far
- Rebase went wrong
- Force push overwrote work
- Cherry-pick conflicts confused you
- You accidentally deleted branches

### Reset (Local Changes)

```bash
# Unstage file (keep changes)
git reset HEAD path/to/file

# Unstage all files (keep changes)
git reset HEAD

# Soft reset (keep changes, move HEAD)
git reset --soft HEAD~1

# Mixed reset (unstage, keep changes)
git reset --mixed HEAD~1

# Hard reset (DESTROYS changes)
git reset --hard HEAD~1
```

**Reset safety:**
- `--soft`: Safe for commits, keeps all work staged
- `--mixed`: Default, unstages but keeps files
- `--hard`: DESTRUCTIVE, cannot be undone without reflog

### Revert (Public History)

```bash
# Revert specific commit
git revert abc1234

# Revert multiple commits
git revert def5678..abc1234

# Revert with no commit (manual edit)
git revert -n abc1234

# Revert merge commit
git revert -m 1 merge_sha
```

**Use revert when:**
- Commit is already pushed/shared
- Need to undo without rewriting history
- Working with team on shared branch

### Restore Files

```bash
# Restore file from last commit
git restore path/to/file

# Restore file from specific commit
git restore --source abc1234 path/to/file

# Restore staged file (unstage)
git restore --staged path/to/file

# Restore deleted file
git restore path/to/deleted.file
```

## Conflict Resolution

**Never resolve conflicts blindly. Always understand the conflict.**

### The Process

```bash
# 1. See what conflicts exist
git status

# 2. Open conflicted files
# Look for: <<<<<<<, =======, >>>>>>> markers

# 3. Understand the conflict
# - Read both sides carefully
# - Check related files for context
# - Run tests if available

# 4. Edit to resolve (remove markers)

# 5. Stage resolved files
git add resolved/file

# 6. Verify all conflicts resolved
git status

# 7. Complete the operation
git commit  # for merge
git rebase --continue  # for rebase
```

### Conflict Markers

```
<<<<<<< HEAD
Current branch's version
=======
Incoming branch's version
>>>>>>> feature/branch
```

### Resolution Strategies

```bash
# Accept current branch (ours)
git checkout --ours path/to/file
git add path/to/file

# Accept incoming branch (theirs)
git checkout --theirs path/to/file
git add path/to/file

# Use merge tool
git mergetool

# See conflict markers inline
git diff
```

**After ANY resolution:**
- Run tests
- Check related files
- Verify functionality
- Read the diff before committing

## Branch Hygiene

```bash
# List branches
git branch

# List branches with latest commit
git branch -v

# List all branches (including remote)
git branch -a

# Delete merged local branch
git branch -d feature/finished

# Force delete unmerged branch
git branch -D feature/abandoned

# Delete remote branch
git push origin --delete feature/finished

# Rename current branch
git branch -m new-name

# Push new branch to remote
git push -u origin feature/new-thing

# Push with force (BE CAREFUL)
git push --force

# Push with lease (SAFER - checks if remote changed)
git push --force-with-lease
```

**Force push rules:**
- NEVER force push to main/master
- Use `--force-with-lease` instead of `--force`
- Coordinate with team before force pushing shared branches
- Check for incoming changes first: `git fetch`

## History Investigation

### Log (Commit History)

```bash
# Show commit history
git log

# Show one-line summary
git log --oneline

# Show graph of branches
git log --graph --oneline --all

# Show history for specific file
git log path/to/file

# Show commits by specific author
git log --author="name"

# Show commits since date
git log --since="2024-01-01"

# Show commits with specific message
git log --grep="keyword"

# Show formatted output
git log --pretty=format:"%h %an %ar %s"

# Show history with stats
git log --stat
```

### Bisect (Find When Bug Appeared)

```bash
# Start bisect
git bisect start

# Mark current as bad
git bisect bad

# Mark known good commit
git bisect good abc1234

# Git will checkout a midpoint - test it
# Mark as good or bad
git bisect good  # or git bisect bad

# Continue until found
git bisect reset  # when done
```

### Blame (Who Changed This Line)

```bash
# Show who changed each line
git blame path/to/file

# Show specific line range
git blame -L 10,20 path/to/file
```

### Show/Diff (View Changes)

```bash
# Show commit details
git show abc1234

# Show file at specific commit
git show abc1234:path/to/file

# Show unstaged changes
git diff

# Show staged changes
git diff --staged

# Show diff between branches
git diff main..feature

# Show diff between commits
git diff abc1234..def5678

# Show word-level diff
git diff --word-diff
```

## Remote Operations

```bash
# Fetch from remote (update remote tracking)
git fetch

# Fetch all remotes
git fetch --all

# Fetch and prune deleted remote branches
git fetch --prune

# Pull (fetch + merge)
git pull

# Pull with rebase
git pull --rebase

# Push current branch
git push

# Push to specific remote branch
git push origin feature/thing

# Push all branches
git push --all

# Push tags
git push --tags

# Set upstream for current branch
git push -u origin feature/thing
```

## Cherry-Pick (Apply Specific Commits)

```bash
# Cherry-pick one commit
git cherry-pick abc1234

# Cherry-pick multiple commits
git cherry-pick def5678..ghi9012

# Cherry-pick without committing
git cherry-pick -n abc1234

# Cherry-pick with edits
git cherry-pick -e abc1234
```

**Use cherry-pick when:**
- Applying specific fix to another branch
- Backporting to release branch
- Reordering commits

## Tags

```bash
# List tags
git tag

# Create annotated tag
git tag -a v1.0.0 -m "Release version 1.0.0"

# Create lightweight tag
git tag v1.0.0

# Delete local tag
git tag -d v1.0.0

# Push tags to remote
git push origin --tags

# Push specific tag
git push origin v1.0.0

# Delete remote tag
git push origin --delete v1.0.0

# Show tag details
git show v1.0.0
```

## Submodules

```bash
# Add submodule
git submodule add https://github.com/user/repo.git path/to/submodule

# Initialize submodules
git submodule init

# Update submodules
git submodule update

# Clone with submodules
git clone --recursive https://github.com/user/repo.git

# Update all submodules to latest
git submodule update --remote
```

## Safety Checklist

Before ANY destructive operation:

```
[ ] I know what branch I'm on (git branch --show-current)
[ ] I know the current state (git status)
[ ] I have no uncommitted work I want to keep
[ ] I understand what this command does
[ ] I have a reflog escape plan if things go wrong
[ ] I'm not force-pushing to a shared branch
[ ] Team is notified if this affects shared work
```

## Common Pitfalls

| Command | Danger | Safer Alternative |
|---------|--------|-------------------|
| `git reset --hard` | Loses uncommitted work | `git stash` first |
| `git push --force` | Overwrites remote history | `git push --force-with-lease` |
| `git rebase main` (public) | Breaks others' work | Use `git merge` |
| `git commit -am "msg"` | Accidentally includes files | `git add -u` first |
| `git checkout .` | Discards all uncommitted work | `git restore` specific files |

## Red Flags - STOP

- About to force push to main/master
- Using `reset --hard` without checking status
- Rebasing shared/public branches
- Cherry-picking without understanding conflicts
- Resolving conflicts by blindly accepting one side
- Deleting branches without checking merge status
- Using `--force` instead of `--force-with-lease`

## Quick Reference Commands

```bash
# Current state
git status
git branch --show-current
git log --oneline -5

# Save work
git add .
git commit -m "message"
git stash push -m "message"

# Share work
git push -u origin branch
git pull --rebase

# Undo
git reflog
git reset --hard HEAD@{1}
git revert abc1234

# Investigate
git log --graph --oneline
git blame file
git bisect start
```

## Best Practices Summary

1. **Always branch** - Never work directly on main/master
2. **Commit often** - Small, atomic commits with clear messages
3. **Use conventional commits** - Structured, searchable messages
4. **Pull before push** - Integrate remote changes first
5. **Rebase local, merge shared** - Clean local history, preserve shared
6. **Force with lease** - Never use bare `--force`
7. **Reflog is safety** - Your escape hatch for mistakes
8. **Test after merge/rebase** - Verify everything works
9. **Clean up branches** - Delete merged branches regularly
10. **Coordinate with team** - Communicate destructive operations
