## Setup Instructions for Fedora

To set up this code on a Fedora system, follow these steps:

1. **Add user:**
  ```bash
  ./adduser.sh
  ```

2. **Install Required Dependencies:**
  Ensure you have all necessary dependencies installed. You can install them using:
  ```bash
  ./setup.sh
  ```

## Reminder for Immutable Fedora Distros (e.g., Bazzite)

If you are using an immutable Fedora distribution like Bazzite, it is recommended to use `distrobox` to set up and run this code. `distrobox` allows you to create and manage containerized environments that can bypass the immutability of the host system.

1. **Install Distrobox:**
  ```bash
  sudo dnf install distrobox
  ```

2. **Create a Distrobox Container:**
  ```bash
  distrobox-create --name my-container --image fedora:latest
  ```

3. **Enter the Distrobox Container:**
  ```bash
  distrobox-enter my-container
  ```

4. **Follow the Setup Instructions Inside the Container:**
  Once inside the container, follow the same setup instructions as mentioned above to install dependencies, clone the repository, and build/run the code.
