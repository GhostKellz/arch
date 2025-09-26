# Git Cheatsheet

A minimal Git reference guide to help you get comfortable with everyday Git workflows. Perfect for beginners!

---

## 🔧 Git Configuration

```bash
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
git config --global init.defaultBranch main
git config --global core.editor nvim   # or nano, code, etc.
```

---

## 📁 Initialize and Clone

```bash
git init                      # Initialize local repo
git clone <repo-url>          # Clone repo from GitHub or other
```

---

## 💾 Staging and Committing

```bash
git status                    # Check current changes
git add <file>                # Stage file
git add .                     # Stage all changes
git commit -m "message"       # Commit staged changes
```

---

## 🔄 Branching & Merging

```bash
git branch                    # List branches
git branch <name>             # Create branch
git checkout <name>           # Switch to branch
git checkout -b <name>        # Create + switch

git merge <branch>            # Merge into current branch
```

---

## 🌐 Remote Repositories

```bash
git remote -v                              # Show remotes
git remote add origin git@github.com:user/repo.git
git push -u origin main                    # Push and set upstream
```

---

## 🔃 Pulling and Pushing

```bash
git pull                                  # Pull latest changes
git push                                  # Push committed changes
```

---

## 🕒 Logs and History

```bash
git log                                   # Full commit log
git log -1                                # Last commit only
git show <commit>                         # Show specific commit
git diff                                  # View unstaged changes
```

---

## 🧼 Undo and Fix

```bash
git restore <file>                        # Undo changes to file
git reset <file>                          # Unstage a file
git commit --amend                        # Edit last commit message
```


## 📁 Repo setup to Github

```bash
touch README.md
touch LICENSE
git init 
git add . 
git commit -m "Initial commit: bootstrap"
gh repo create ghostkellz/NAMEDREPO --public --source=. --remote=origin --push
git remote -v
git push -u origin main
```

---

## 🛠 Helpful Tips

- `.gitignore` – Add files you don't want to track
- Use `git stash` to temporarily save work
- `git config --list` – See all global/local config
- Add SSH key to GitHub for seamless auth

---

For more: [https://git-scm.com/docs](https://git-scm.com/docs) or use `man git`

