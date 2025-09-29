# Using Docker or Podman on Immutable Systems

Immutable systems like Bazzite and SteamOS are designed to have a read-only root filesystem, which can make traditional package installations and configurations challenging. However, tools like Docker and Podman can still be used effectively with some considerations.

## Docker

Docker is a popular containerization platform, but on immutable systems, you need to account for its specific requirements:

### Rootless Docker

Using Docker in rootless mode is highly recommended to avoid conflicts with system files and improve security. This is especially important when working with tools like VSCode's Dev Containers.

#### Install Rootless Docker

  Follow the official Docker documentation for setting up rootless mode:
  [Rootless Docker Installation Guide](https://docs.docker.com/engine/security/rootless/).

#### **Configure Environment**

  Ensure your user has the necessary permissions and environment variables set up. For example:

  ```bash
  export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock
  ```

#### **Persistent Storage**

  Since the root filesystem is read-only, use external drives or user home directories for persistent storage. Bind mount volumes like this:

  ```bash
  docker run -v ~/mydata:/data myimage
  ```

### Additional Notes (Docker)

- Docker may require additional configuration to work with the immutable system's kernel modules.
- Use `systemd` user services for managing the Docker daemon in rootless mode.

---

## Podman

Podman is a daemonless container engine that works well on immutable systems. It is often preferred for its simplicity and compatibility with Docker CLI commands.

### Why Podman?

- **Daemonless**: No need for a running daemon, making it lightweight.
- **Rootless by Default**: Podman is designed to run containers as a non-root user.
- **Compatibility**: Supports Dockerfile and Docker Compose (via `podman-compose`).

### Setting Up Podman

#### Install Podman

  On immutable systems, use a toolbox or flatpak to install Podman. For example:

  ```bash
  flatpak install flathub org.podman.Podman
  ```

#### Run Containers

  Use Podman commands similar to Docker:

  ```bash
  podman run -v ~/mydata:/data myimage
  ```

#### Toolbox Integration

  On systems like Fedora Silverblue or SteamOS, Podman integrates well with `toolbox` for development environments.

### Additional Notes (Podman)

- Podman does not require a daemon, so it avoids some of the complexities of Docker on immutable systems.
- Use `podman generate systemd` to create systemd service files for managing containers.

---

## General Tips for Immutable Systems

- Use `toolbox` or `distrobox` for creating mutable environments within immutable systems.
- Store container images and volumes in user-writable directories.
- Regularly update container images to ensure compatibility with the host system.

For more localized support, check out community forums or documentation specific to your immutable OS.
