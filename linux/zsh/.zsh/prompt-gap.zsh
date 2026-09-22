# One blank separator line above every prompt except the first of the shell
# process and the first after the screen was wiped. See ADR-0003 / issue #270.
#
# The newline is PRINTED here rather than carried inside PROMPT. That is the
# whole point: Ctrl-L wipes the screen and repaints PROMPT without firing any
# hook, so a printed newline is simply gone, while one embedded in PROMPT would
# come back on the row the user just cleared. The same property makes the
# separator immune to `zle reset-prompt` (starship's own vi-keymap redraw) and
# to SIGWINCH repaints, neither of which can duplicate it.
#
# The flag is armed on the FIRST precmd, never in preexec: zsh fires no preexec
# for a bare Enter, nor for Ctrl-C on a line that was typed but never submitted,
# and both of those must still produce a separator (#270 AC-003/AC-004).
#
# PRESERVED across a re-source, never reset. `source ~/.zshrc` is routine right
# after editing the rc, and it re-runs this file in a shell that has already
# drawn prompts. A plain `=0` would disarm the flag and cost the NEXT prompt its
# separator -- a MISSING row, which is the direction ADR-0003 Implementation
# Guidance 9 forbids. Measured before this guard existed; see the Design Doc.
# `add-zsh-hook` is idempotent, so the registrations below need no equivalent.
typeset -g _dotfiles_prompt_gap_armed=${_dotfiles_prompt_gap_armed:-0}

_dotfiles_prompt_gap() {
    if (( _dotfiles_prompt_gap_armed )); then
        print -n -- $'\n'
    else
        _dotfiles_prompt_gap_armed=1
    fi
}

# Ctrl-L needs no handling at all -- it fires no hook. The `clear` command does
# fire precmd, and a separator there would put a blank row at the top of a
# freshly wiped screen: exactly the complaint in #270.
#
# Matched exactly, never loosely: a command that merely CONTAINS "clear"
# silently losing its separator fails in the direction nobody notices.
#
# Matched against $3 (the fully alias-expanded line), not $1 (as typed).
# Both are exact matches -- expansion and exactness are separate axes -- but
# $3 also resolves `alias cls=clear` and trims a trailing space, closing two
# residuals for free. Measured: for `cls`, $1=cls and $3=clear; for `clear `,
# $1="clear " and $3=clear. bash cannot follow suit (its history stores the
# pre-expansion line), so bash keeps the alias residual; see the Design Doc.
_dotfiles_prompt_gap_disarm() {
    case "$3" in
        clear|reset|'tput clear'|'tput reset') _dotfiles_prompt_gap_armed=0 ;;
    esac
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd _dotfiles_prompt_gap
add-zsh-hook preexec _dotfiles_prompt_gap_disarm
