# Post-setup resources

.dotfiles has various programs that can be executed even after the setup script.

Here's some items below:

|Command|Description|Remarks|
|----|-----|-------|
|dotfiles-homebrew|Homebrew installer ([brew.sh](https://brew.sh))||
|dotfiles-ruby|Ruby version Manager using `rbenv`|Currently unstable; Requires more testing on some devices & Linux distros|
|dotfiles-python|Python version Manager using `pyenv`||
|dotfiles-nodejs|NodeJS version Manager using `nvm`||
|dotfiles-java-sdkman|Java version Manager using `SDKMAN`||
|dotfiles-distro|Generates the current Linux distribution|Used internally for installing stuff|
|lindbergh-id5|Play "Initial D Arcade Stage 5" ([Gameplay](https://youtu.be/kjkMN6xHoPw))|Uses Lindbergh Loader for running SEGA Lindbergh Yellow which is based on Debian|
|lindbergh-outrun2|Play "Outrun 2 SP SDX" ([Gameplay](https://youtu.be/XSg0Ehoj0Mk))|Uses Lindbergh Loader for running SEGA Lindbergh Yellow which is based on Debian|
|dotfiles-vim|Installing plugins on Vim using `vim-plug`||
|dotfiles-bash|Installing custom shell profiles for Bash|Default shell is set to `zsh`. This is optional.|

## Shell Script template

You can create your own shell script template, but do keep in mind that it needed to be installed on `~/.local/bin`, to prevent having issues when updating `.dotfiles`.

Located file:

`~/.local/bin/org.jcchikikomori.dotfiles/bin/bin-template`

## External resources

### Ubuntu/Debian

Under Construction

### Arch Linux

- Use `yay` to search packages that are available for your system
- Please read the [documentation for Arch Linux](https://wiki.archlinux.org/title/Main_page), which is contains valuable information on what you can do on your system.

### Steam Deck

- [Awesome Steam Deck](https://gist.github.com/jcchikikomori/9f2bdb2bec0c30f3a822212c1b303da4)
- [Steam Deck Resources](https://sdeck.wiki/)
