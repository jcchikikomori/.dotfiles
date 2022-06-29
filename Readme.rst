========
Dotfiles
========

This is my collection of `configuration files <http://dotfiles.github.io/>`_ for bash, vim, zsh, tmux and plenty others.

Configurations are managed by `dotstow <https://github.com/codejamninja/dotstow>`_ or simply stow (if you don't have dotstow installed or want to get it installed!)


To setup:

- Install gnu stow

    .. code-block:: bash

        # For Ubuntu users
        sudo apt update -y; sudo apt install stow -y

        # For redhat (dnf managed distros)
        sudo dnf install stow -y

- Upgrade nodejs to the minimum version of 12. (You can use nvm to configure as well). This step is optional if you want to configure dotstow.

    .. code-block:: bash

        # For ubuntu
        sudo apt install build-essential apt-transport-https lsb-release ca-certificates curl
        curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
        which node npm

- Install dotstow

    .. code-block:: bash

        npm install dotstow

- Download your dotfiles and bootstrap the environment

    .. code-block:: bash

        ~/node_modules/.bin/dotstow bootstrap --remote https://github.com/sreerajkksd/dotfiles.git


- Set the configs

    .. code-block:: bash

        ~/node_modules/.bin/dotstow stow bash git i3 systems tmux vim vscode zsh -f

And we are done. You should see symlinks on your home directory for all the dotfiles and others.

- To pull the configs from the remote
    .. code-block:: bash

        ~/node_modules/.bin/dotstow pull

- To update the configs
   - Upload changes the repository and commit the changes.
   - Run `dotstow sync`

Note:

- If you only have stow installed and want only to update certain configs (without touching others eg: on a work environment), you can do the following

    .. code-block:: bash

        # Clone the repository
        git clone -q --depth 1 https://github.com/sreerajkksd/dotfiles.git ~/.dotfiles

        #Initialize the configs
        $HOME/.dotfiles/manual-init.sh

        # Check available environments and packages
        tree $HOME/.dotfiles/ -L 2

        # Stow the packages as you like
        stow -t $HOME -d $HOME/.dotfiles/<Environment>/ <Package>

        # example: stow -t $HOME -d $HOME/.dotfiles/linux bash zsh vscode vim tmuxh systems i3 git


=======
Credits
=======

 - Sreeraj Karichery (sreerajmylatty@gmail.com)
