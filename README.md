# dotfiles

How to clone this repository:

```bash
git clone --separate-git-dir "$HOME/.local/dotfiles" --branch <branch> <repo-url>
rm -rf dotfiles/ # we don't need the initial worktree
git --git-dir="$HOME/.local/dotfiles" --work-tree="$HOME" reset --hard
dotfiles config status.showUntrackedFiles no
```
