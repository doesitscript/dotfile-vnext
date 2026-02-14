# Podman Role for mac-dev

Installs and configures Podman on macOS with Docker-compatible aliases and Podman Desktop UI.

## Purpose

This role provides:
- Podman container runtime installation
- Podman Compose for docker-compose compatibility
- Podman Desktop graphical UI
- Docker-compatible shell aliases (`docker` → `podman`, `docker-compose` → `podman-compose`)
- Automatic podman machine initialization and startup

## What Gets Installed

1. **podman** - Container runtime (via Homebrew)
2. **podman-compose** - Docker Compose compatibility layer (via Homebrew)
3. **podman-desktop** - Graphical UI application (via Homebrew Cask)
4. **podman machine** - Virtual machine for running containers on macOS (auto-initialized)

## Configuration

No configuration variables are required. The role automatically:
- Detects your shell (zsh/bash) and adds aliases to the appropriate config file
- Initializes a podman machine if one doesn't exist
- Starts the podman machine if it's not running

## Usage

After running this role:

1. **Restart your terminal** or run:
   ```bash
   source ~/.zshrc  # or ~/.bashrc
   ```

2. **Use docker commands** - They will automatically use podman:
   ```bash
   docker ps
   docker pull nginx
   docker run -d -p 8080:80 nginx
   ```

3. **Use docker-compose commands** - They will use podman-compose:
   ```bash
   docker-compose up -d
   docker-compose ps
   docker-compose down
   ```

4. **Launch Podman Desktop UI**:
   ```bash
   open -a "Podman Desktop"
   ```
   Or find it in Applications.

## Docker Compatibility

The role creates shell aliases that make podman work like docker:
- `docker` → `podman`
- `docker-compose` → `podman-compose`

This means existing docker commands, scripts, and docker-compose files will work without modification.

## Podman Machine

On macOS, Podman runs containers inside a Linux virtual machine. The role automatically:
- Creates a podman machine if one doesn't exist
- Starts the machine if it's not running

To manually manage the machine:
```bash
podman machine list
podman machine start
podman machine stop
podman machine restart
```

## Verification

After installation, verify everything works:
```bash
# Check podman version
podman version

# Check podman machine status
podman machine list

# Test docker alias
docker ps

# Test docker-compose alias
docker-compose --version
```

## Notes

- Podman Desktop UI provides a graphical interface for managing containers, images, and pods
- The podman machine runs in the background and starts automatically when needed
- All docker-compatible commands work through the aliases
- Podman is rootless by default, which is more secure than Docker



