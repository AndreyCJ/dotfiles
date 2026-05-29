#!/bin/bash

# ============================================
# macOS / Finder настройки
# ============================================

# Finder: показывать скрытые файлы
# defaults write com.apple.finder AppleShowAllFiles -bool true

# Finder: показывать все расширения файлов
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Finder: показывать путь внизу окна (Path Bar)
defaults write com.apple.finder ShowPathbar -bool true

# Finder: показывать строку состояния
defaults write com.apple.finder ShowStatusBar -bool true

# Finder: вид по умолчанию — список
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Finder: новые окна открываются в домашней папке
defaults write com.apple.finder NewWindowTarget -string "PfLo"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}"

# Finder: папки всегда сверху
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# Finder: отключить предупреждение при смене расширения
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Finder: удалять файлы из корзины через 30 дней
defaults write com.apple.finder FXRemoveOldTrashItems -bool true

# Другие популярные настройки
defaults write com.apple.finder QuitMenuItem -bool true           # Можно Quit Finder (Cmd+Q)
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# Dock
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock tilesize -int 48

# Глобальные
defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 15
defaults write NSGlobalDomain AppleShowScrollBars -string "Always"

# screenshot folder
mkdir -p ~/Pictures/Screenshots
defaults write com.apple.screencapture location ~/Pictures/Screenshots

# Применить изменения
killall Finder
killall Dock
killall SystemUIServer