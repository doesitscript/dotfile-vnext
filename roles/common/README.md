https://www.wenbo.io/en-US/Tools/Persistent-VSCode-Remote-Terminals



Wenbo Pan

Search



Home
❯

Tools
❯

Persistent VSCode Remote Terminals with tmux
Persistent VSCode Remote Terminals with tmux
Nov 05, 20258 min read

English
简体中文
Summary: VSCode’s remote terminal is incredibly convenient for daily development, but it has a long-standing issue: once VSCode disconnects, all processes in the terminal are forcibly terminated. This article introduces a simple yet complete solution—just add one configuration line to VSCode’s settings.json to automatically attach each VSCode terminal to an independent tmux session. This way, terminal processes continue running even after network interruptions or window closures. Compared to manually using tmux, this approach preserves all VSCode terminal features, including shell integration, copy-paste support, plugin monitoring, and the code command.

We use VSCode’s Remote SSH feature daily to connect to remote hosts. Whether it’s experiments on servers, code debugging, or long-running tasks, VSCode’s integrated terminal is incredibly convenient. But almost everyone has encountered this problem: once VSCode disconnects, all running processes in the terminal are immediately killed.

Maybe it’s just a network hiccup, or you closed your laptop and reopened it—whatever was halfway through running is completely gone. This article introduces a simple but highly effective solution: with just one line of configuration, you can automatically mount each VSCode terminal to an independent tmux session. This way, even if the connection drops, you can seamlessly resume your terminal environment with all commands, processes, and output intact.

Why This Configuration is Needed
The VSCode Remote SSH extension makes the boundary between local and remote almost invisible. Files, terminals, debuggers, and Git operations all feel as smooth as working locally. But it has one inherent shortcoming: VSCode terminals are bound to the SSH connection. When VSCode disconnects, the terminal is considered to have no foreground user, and processes are naturally cleaned up by the system.

An obvious solution is to use tmux. Tmux is a terminal multiplexer that allows processes to exist independently of the SSH client. Even if disconnected, you can reattach to the original session with tmux attach. However, running tmux directly inside VSCode has several notable issues:

VSCode Shell Integration doesn’t work. VSCode’s command-line integration relies on the terminal itself, not what’s inside tmux.
The code command fails. VSCode provides the code command for conveniently opening files from the command line. Due to the isolation between subprocess environments in tmux and VSCode’s IPC communication mechanism, you can’t use code . to open files inside tmux.
Fragmented interaction experience. Tmux has its own window and split-pane management system, while VSCode uses more intuitive, WYSIWYG tabs.
Actually, with just one simple configuration line (though the line itself is a bit complex), we can achieve the best of both worlds: make each VSCode terminal correspond to a unique, persistent tmux session in the background, so that even if the network disconnects or you accidentally close the window, it can automatically reconnect. At the same time, this configuration ensures that most of VSCode’s terminal integration features continue to work normally.

Core Configuration
Add the following to VSCode’s settings.json:


"terminal.integrated.profiles.linux": {
    "tmux-tab": {
        "path": "/bin/bash",
        "args": [
            "-c",
            "printf '\\e]633;A\\a\\e]633;B\\a\\e]633;E;tmux new-session -s vsct-$$ -c \"%s\"\\a\\e]633;C\\a' \"$PWD\"; vars=(TERM_PROGRAM TERM_PROGRAM_VERSION VSCODE_IPC_HOOK_CLI VSCODE_IPC_HOOK VSCODE_PID VSCODE_CWD VSCODE_NLS_CONFIG VSCODE_GIT_IPC_HANDLE VSCODE_INJECTION VSCODE_SHELL_INTEGRATION); eargs=(); for v in \"${vars[@]}\"; do eargs+=( -e \"$v=${!v}\" ); done; tmux new-session -d -s vsct-$$ -c \"$PWD\" \"${eargs[@]}\"; tmux set -t vsct-$$ status off; exec tmux attach -t vsct-$$"
        ]
    }
},
This configuration creates an independent tmux session vsct-<bash pid> in the background each time you create a new tmux-tab terminal tab, then automatically attaches to it. The core of this command is simple, but it has many decorative commands and preprocessing steps around it to make VSCode’s terminal integration work properly. Let’s break it down line by line:


printf '\e]633;A\a\e]633;B\a\e]633;E;
tmux new-session -s vsct-$$ -c "%s"\a\e]633;C\a' "$PWD";
 
vars=(TERM_PROGRAM TERM_PROGRAM_VERSION VSCODE_IPC_HOOK_CLI VSCODE_IPC_HOOK VSCODE_PID VSCODE_CWD VSCODE_NLS_CONFIG VSCODE_GIT_IPC_HANDLE VSCODE_INJECTION VSCODE_SHELL_INTEGRATION);
 
eargs=();
for v in "${vars[@]}"; do
    eargs+=( -e "$v=${!v}" );
done;
 
tmux new-session -d -s vsct-$$ -c "$PWD" "${eargs[@]}";
tmux set -t vsct-$$ status off;
exec tmux attach -t vsct-$$
First segment: Send shell integration signals to VSCode.


printf '\e]633;A\a\e]633;B\a\e]633;E;tmux new-session -s vsct-$$ -c "%s"\a\e]633;C\a' "$PWD"
This sends VSCode’s custom OSC 633 sequences, indicating in order: prompt start (A), prompt end (B), explicitly set “command line to execute” (E), and “ready to execute” (C). We write the “command line” as tmux new-session -s vsct-$$ -c "<current directory>", essentially telling VSCode: we’re about to enter tmux, and here’s the current directory. This allows VSCode to continue displaying command decorations, tracking directories, and supporting features like “go to recent directory”. This input sequence provides VSCode shell integration.

Second segment: Prepare environment variables to pass into tmux.


vars=(TERM_PROGRAM … VSCODE_SHELL_INTEGRATION)
eargs=()
for v in "${vars[@]}"; 
do eargs+=( -e "$v=${!v}" ); 
done;
Tmux’s new-session supports -e name=value to set environment variables for new sessions. We pass in the key variables that VSCode places in the terminal, such as VSCODE_IPC_HOOK_CLI, VSCODE_CWD, etc. Passing these variables solves the problem of being unable to use the code command inside tmux: running code <path> inside tmux can still hand the file back to this VSCode client, because code communicates with VSCode through the socket specified in VSCODE_IPC_HOOK_CLI.

Third segment: Create and attach to an independent tmux session.


tmux new-session -d -s vsct-$$ -c "$PWD" "${eargs[@]}";
tmux set -t vsct-$$ status off; 
exec tmux attach -t vsct-$$
This part of the command first creates a session in the background with -d, then attaches to it; -c "$PWD" makes the session start from the current directory; -s vsct-$$ uses bash’s process number to ensure the session name is unique for each VSCode tab; status off disables tmux’s own status bar for a cleaner interface.

After this series of commands, each time you open a new terminal in VSCode, it automatically corresponds to an independent tmux session, completely transparent, with all VSCode integration features still functional. Even if you disconnect or close VSCode, the next time you reopen it, the new terminal will automatically reconnect to the same-named session.

Making the Experience Perfect
This configuration already works, but we can make it more elegant and closer to daily use.

Set as Default Profile

"terminal.integrated.defaultProfile.linux": "tmux-tab",
"terminal.integrated.automationProfile.linux": {
    "path": "/bin/bash",
    "args": ["-lc", "exec $SHELL -l"]
},
This way, manually opened terminals all use tmux-tab, while automated tasks (like debuggers) use regular shell, avoiding interference.

Adjust Tmux Configuration
Add the following to ~/.tmux.conf on the remote host. The goal is to make tmux as unobtrusive as possible in VSCode and ensure advanced features can pass through to the outer terminal.


# ~/.tmux.conf
 
setw -g automatic-rename on
set -g allow-rename on
set -g mouse on
set -g allow-passthrough on      # Allow escape sequences to reach outer terminal, recommended for tmux 3.3+
set -g default-terminal "tmux-256color"
 
# Clipboard: Let tmux interface with system clipboard through terminal's OSC 52 mechanism
set -g set-clipboard on          # Whether it works depends on terminal support
# If you have tools that can send OSC 52 (like osc, tty-copy), you can also unify the copy outlet:
# set -s copy-command 'osc copy'   # or 'tty-copy'
 
# In VSCode, "copy on mouse select" is unnecessary; let outer VSCode handle it more naturally
set -g @yank_with_mouse off
allow-passthrough on allows graphics protocols or clipboard sequences to “pass through” tmux to the outer terminal—supported by modern tmux versions; set-clipboard on works with OSC 52 (escape sequence for copying to system clipboard) to copy text from remote tmux to local clipboard; and copy-command is a unified copy outlet introduced in tmux 3.2, which can be specified as an external tool (like xsel -i, xclip, or the aforementioned OSC 52 tools). Whether it works depends on the outer terminal’s OSC 52 support.

Automatically Clean Up Idle Sessions
As usage increases, you might accumulate many unattached vsct-* sessions. You can periodically run the following script to automatically clean up sessions without active processes:


# Prune detached vsct* tmux sessions without active foreground jobs (zsh)
prune_vsct_tmux() {
  if ! command -v tmux >/dev/null 2>&1; then
    echo "tmux command not found" >&2
    return 1
  fi
 
  local sessions
  sessions=$(tmux list-sessions -F "#{session_name}::#{session_attached}" 2>/dev/null) || return 0
 
  local -a idle=(fish bash zsh sh)
  local killed=0
 
  local line name attached panes pane_cmd lower has_active in_idle
  setopt localoptions shwordsplit
 
  for line in ${(f)sessions}; do
    name=${line%%::*}
    attached=${line##*::}
 
    [[ $name == vsct* ]] || continue
    [[ -n "$attached" && $attached -gt 0 ]] && continue
 
    panes=$(tmux list-panes -t "$name" -F "#{pane_current_command}" 2>/dev/null) || continue
    has_active=0
 
    for pane_cmd in ${(f)panes}; do
      [[ -z "$pane_cmd" ]] && continue
      lower=${pane_cmd:l}
 
      in_idle=0
      for _c in $idle; do
        [[ "$lower" == "$_c" ]] && in_idle=1 && break
      done
 
      if [[ $in_idle -eq 0 ]]; then
        has_active=1
        break
      fi
    done
 
    if [[ $has_active -eq 0 ]]; then
      tmux kill-session -t "$name" && ((killed++))
    fi
  done
}
This script checks all sessions starting with vsct, and automatically cleans them up if they have no attached clients and no running programs inside.

Summary
Through this configuration, we can give VSCode’s remote terminal persistent, transparent, and automated characteristics:

Each VSCode terminal automatically binds to an independent tmux session.
Even if disconnected or VSCode is closed, processes inside the session continue running.
All VSCode integration features (like shell integration, copy-paste, code command) remain functional.
Optional scripts and configurations make the experience more natural and cleaner.
Graph View

Created with Quartz v4.5.0 © 2025

Google Scholar
GitHub
Hugging Face
RedNote
Persistent VSCode Remote Terminals with tmux