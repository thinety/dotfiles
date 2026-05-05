if status is-login
    set PATH \
        "$HOME/.local/bin" \
        "$HOME/.cargo/bin" \
        "$HOME/.go/bin" \
        "$HOME/.cabal/bin" \
        "$HOME/.ghcup/bin" \
        $PATH

    set -gx GOPATH "$HOME/.go"

    set -gx EDITOR nvim
end

if status is-interactive
    if set -q GHOSTTY_RESOURCES_DIR
        source "$GHOSTTY_RESOURCES_DIR"/shell-integration/fish/vendor_conf.d/ghostty-shell-integration.fish
    end
end
