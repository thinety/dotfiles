function dotfiles
    git --git-dir="$HOME/.local/dotfiles" --work-tree="$HOME" $argv
end
