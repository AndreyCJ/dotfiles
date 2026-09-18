#!/bin/bash

podman run --rm -it \
  --userns=keep-id \
  -v "$PWD":/workspace:Z \
  -v "$HOME/.config/opencode":/home/coder/.config/opencode:Z \
  -v "$HOME/.local/share/opencode":/home/coder/.local/share/opencode:Z \
  -w /workspace \
  ghcr.io/anomalyco/opencode "$@"
