function fish_title
    set -l command "$(status current-command)"
    set -l cwd "$(string replace --regex "^$HOME" '~' "$PWD")"

    test $command = fish; and set command

    echo -- $command $cwd
end
