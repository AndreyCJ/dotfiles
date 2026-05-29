#!/usr/bin/env bash

echo "Applying macOS settings..."

# fast key repeat
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# show hidden files
defaults write com.apple.finder AppleShowAllFiles YES

# disable .DS_Store on network drives
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

# screenshot folder
mkdir -p ~/Screenshots
defaults write com.apple.screencapture location ~/Screenshots

# restart affected apps
killall Finder
