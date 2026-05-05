# dotfiles

How to clone this repository:

```bash
git clone --bare <repo-url> "$HOME/.local/dotfiles"
git --git-dir="$HOME/.local/dotfiles" --work-tree="$HOME" switch <branch>
dotfiles config status.showUntrackedFiles no
```
