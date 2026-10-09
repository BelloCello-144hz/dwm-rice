# ~/.config/fish/config.fish - Nord fish configuration

# ---------- environment ----------
if type -q nvim
    set -gx EDITOR nvim
else
    set -gx EDITOR nano
end
set -gx VISUAL $EDITOR
set -gx TERMINAL kitty
fish_add_path -g $HOME/.local/bin

# Source any local functions / snippets (~/.config/fish/local/*.fish)
set -l local_dir $__fish_config_dir/local
if test -d $local_dir
    for f in $local_dir/*.fish
        source $f
    end
end
if test -d $__fish_config_dir/functions.local
    set -p fish_function_path $__fish_config_dir/functions.local
end

if not status is-interactive
    return
end

# ---------- Nord palette ----------
set -g nord0 2E3440
set -g nord1 3B4252
set -g nord3 4C566A
set -g nord4 D8DEE9
set -g nord6 ECEFF4
set -g nord7 8FBCBB
set -g nord8 88C0D0
set -g nord9 81A1C1
set -g nord10 5E81AC
set -g nord11 BF616A
set -g nord12 D08770
set -g nord13 EBCB8B
set -g nord14 A3BE8C
set -g nord15 B48EAD

# Syntax highlighting
set -g fish_color_normal $nord4
set -g fish_color_command $nord8
set -g fish_color_keyword $nord9
set -g fish_color_quote $nord14
set -g fish_color_redirection $nord15
set -g fish_color_end $nord9
set -g fish_color_error $nord11
set -g fish_color_param $nord4
set -g fish_color_comment $nord3
set -g fish_color_operator $nord9
set -g fish_color_escape $nord13
set -g fish_color_autosuggestion $nord3
set -g fish_color_valid_path --underline
set -g fish_color_cwd $nord8
set -g fish_color_user $nord14
set -g fish_color_host $nord9
set -g fish_color_search_match --background=$nord1
set -g fish_color_selection --background=$nord1
set -g fish_pager_color_progress $nord3
set -g fish_pager_color_prefix $nord8
set -g fish_pager_color_completion $nord4
set -g fish_pager_color_description $nord3

set -g fish_greeting ""

# ---------- aliases ----------
alias ls 'ls --color=auto'
alias ll 'ls -la --color=auto'
alias la 'ls -A --color=auto'
alias grep 'grep --color=auto'
alias ..  'cd ..'
alias ... 'cd ../..'
alias v   '$EDITOR'
alias gs  'git status'
alias gd  'git diff'
alias gl  'git log --oneline --graph --decorate -n 20'
alias update 'sudo pacman -Syu'
alias cleanup 'sudo pacman -Rns (pacman -Qtdq)'

# ---------- prompt ----------
# user@host ~/dir (branch) ❯
function fish_prompt
    set -l last_status $status

    set_color $nord14
    printf '%s' $USER
    set_color $nord3
    printf '@'
    set_color $nord9
    printf '%s ' (prompt_hostname)
    set_color --bold $nord8
    printf '%s' (prompt_pwd)
    set_color normal

    if command -q git
        set -l branch (git symbolic-ref --short HEAD 2>/dev/null; or git rev-parse --short HEAD 2>/dev/null)
        if test -n "$branch"
            set_color $nord15
            printf ' (%s' $branch
            if test -n "$(git status --porcelain 2>/dev/null)"
                set_color $nord13
                printf '*'
            end
            set_color $nord15
            printf ')'
        end
    end

    if test $last_status -ne 0
        set_color $nord11
    else
        set_color $nord8
    end
    printf ' ❯ '
    set_color normal
end

function fish_right_prompt
    set_color $nord3
    date '+%H:%M'
    set_color normal
end
