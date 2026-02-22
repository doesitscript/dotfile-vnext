# WSL-specific functions for Windows path conversion
# Uses WSL's built-in wslpath command

# Only load these functions if running in WSL
if [[ -n "$WSL_DISTRO_NAME" ]] || grep -qi microsoft /proc/version 2>/dev/null; then

    # Convert Windows path to Linux path and cd to it
    # Usage: cdw "C:\Users\joshc\develop\workflows"
    cdw() {
        if [[ -z "$1" ]]; then
            echo "Usage: cdw <windows-path>"
            echo "Example: cdw 'C:\\Users\\joshc\\develop'"
            return 1
        fi
        local linpath
        linpath=$(wslpath -u "$1" 2>/dev/null)
        if [[ -n "$linpath" ]]; then
            cd "$linpath" || return 1
        else
            echo "Error: Could not convert path '$1'"
            return 1
        fi
    }

    # Convert Windows path to Linux path (just print, don't cd)
    # Usage: wpath "C:\Users\joshc\develop\workflows"
    # Or in command: ls $(wpath "C:\Users\joshc\develop")
    wpath() {
        if [[ -z "$1" ]]; then
            echo "Usage: wpath <windows-path>"
            echo "Example: wpath 'C:\\Users\\joshc\\develop'"
            return 1
        fi
        wslpath -u "$1"
    }

    # Convert Linux path to Windows path
    # Usage: lpath /mnt/c/Users/joshc
    lpath() {
        if [[ -z "$1" ]]; then
            echo "Usage: lpath <linux-path>"
            echo "Example: lpath /mnt/c/Users/joshc"
            return 1
        fi
        wslpath -w "$1"
    }

fi

