set -g fish_greeting

if status is-interactive
    set -gx EDITOR micro
    set -gx VISUAL micro

    if command -q zoxide
        zoxide init fish | source
    end

    if command -q fzf
        fzf --fish | source
    end

    if command -q atuin
        atuin init fish | source
    end
end

function fish_prompt
    set -l last_status $status

    set_color brblack
    printf '['

    set_color brcyan
    printf '%s' (prompt_pwd)

    set_color brblack
    printf ']'

    if test $last_status -ne 0
        set_color brred
        printf ' %s' $last_status
    end

    set_color brmagenta
    printf ' ❯ '

    set_color normal
end

# Check if the shell is interactive and not already nested inside a tmux session
if status is-interactive
    and not set -q TMUX
    and command -q tmux
    # Create a new session named 'main' or attach to it if it already exists
    exec tmux new-session -A -s main
end


# kilo
fish_add_path /home/asad/.kilo/bin

# >>> railway initialize >>>
source "$HOME/.railway/env.fish"
# <<< railway initialize <<<
