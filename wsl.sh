#!/bin/sh

# Share credentials between Windows & WSL
# Reference: https://dev.to/equiman/sharing-git-credentials-between-windows-and-wsl-5a2a
#
# On Windows, make sure `git-credential-manager-for-windows` package is required, otherwise
# execute on your PowerShell (Admin): choco install git-credential-manager-for-windows
git config --global credential.helper wincred
git config --global credential.helper "/mnt/c/Program\ Files/Git/mingw64/bin/git-credential-manager.exe"
