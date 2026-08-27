if status is-login
    set PATH \
        "$HOME/.local/bin" \
        "$HOME/.cargo/bin" \
        "$HOME/.go/bin" \
        "$HOME/.ghcup/bin" \
        $PATH

    set -gx GOPATH "$HOME/.go"

    set -gx EDITOR nvim
end

fish_vi_key_bindings
