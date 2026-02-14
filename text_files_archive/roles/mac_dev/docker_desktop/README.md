# Docker Desktop Role for mac-dev

Installs and configures Docker Desktop on macOS with UI.

## Purpose

This role provides:
- Docker Desktop installation (with graphical UI)
- Docker and Docker Compose CLI tools
- Automatic Docker Desktop startup

## What Gets Installed

1. **Docker Desktop** - Full Docker environment with UI (via Homebrew Cask)
   - Includes Docker Engine, Docker CLI, Docker Compose
   - Includes Docker Desktop application with graphical interface

## Configuration

No configuration variables are required. The role automatically:
- Installs Docker Desktop via Homebrew
- Starts Docker Desktop if it's not running
- Verifies Docker is working

## Usage

After running this role:

1. **Docker Desktop UI** will be available in Applications
2. **Use docker commands**:
   ```bash
   docker ps
   docker pull nginx
   docker run -d -p 8080:80 nginx
   ```

3. **Use docker-compose commands**:
   ```bash
   docker-compose up -d
   docker-compose ps
   docker-compose down
   ```

4. **Launch Docker Desktop UI**:
   ```bash
   open -a Docker
   ```
   Or find it in Applications.

## Mac-Only

This role is **ONLY for macOS development machines** (control plane), not infrastructure nodes:
- Infrastructure nodes use their own Docker runtime roles
- This role has explicit OS checks to prevent running on Windows/Linux
- Located in `mac_dev/` namespace for clear organization

## Notes

- Docker Desktop supports macOS 12 (Monterey) and later
- First launch may take a moment to initialize
- Docker Desktop runs in the background and starts automatically on login (configurable in UI)


