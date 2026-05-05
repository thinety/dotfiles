function fish_prompt
    set -l last_status $status

    set_color --bold

    set_color blue
    echo -n "$USER"

    set_color brblack
    echo -n '@'

    set_color yellow
    echo -n "$hostname"

    set_color brblack
    echo -n ':'

    set_color cyan
    echo -n (string replace --regex "^$HOME" '~' "$PWD")

    set_color normal
    set -q ZMX_SESSION; and echo -n " [$ZMX_SESSION]"
    echo

    set_color brblack
    echo -n (date '+%H:%M:%S')

    set_color normal
    echo -n ' '

    set_color --bold
    test "$last_status" -eq 0; and set_color green; or set_color red
    test "$EUID" -ne 0; and echo -n '$'; or echo -n '#'

    set_color normal
    echo -n ' '
end
