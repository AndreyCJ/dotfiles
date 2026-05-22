# My dotfiles

This directory contains the dotfiles for my OSX system

## Requirements

Ensure you have the following installed on your system


### Stow

```
brew install stow
```

## Installation

First, check out the dotfiles repo in your $HOME directory using git

```
$ git clone git@github.com:AndreyCJ/dotfiles.git
$ cd dotfiles
```

then use GNU stow to create symlinks

```
$ stow .
```


### Creating a specific symlink to the config dir:

first 
```
$ mv ~/.config/$dir ~/dotfiles/.config
```

then

```
$ ln -s ~/dotfiles/.config/$dir ~/.config/$dir
```

