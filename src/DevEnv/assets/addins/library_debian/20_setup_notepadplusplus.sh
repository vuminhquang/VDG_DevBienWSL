#!/bin/bash

# allow using Notepad++ to open file in wsl, typeing npp file name

# Function to add alias if it doesn't already exist
add_alias() {
  local shell_config_file="$1"
  local alias_command='alias npp="/mnt/c/Program\ Files/Notepad++/Notepad++.exe"'

  # Check if alias already exists
  if ! grep -q "$alias_command" "$shell_config_file"; then
    echo "Adding alias to $shell_config_file"
    echo "$alias_command" >> "$shell_config_file"
    echo "Alias added successfully."
  else
    echo "Alias already exists in $shell_config_file"
  fi

  # Source the configuration file to apply changes
  source "$shell_config_file"
}

# Detect shell and corresponding configuration file
if [[ -n "$BASH_VERSION" ]]; then
  shell_config_file="$HOME/.bashrc"
elif [[ -n "$ZSH_VERSION" ]]; then
  shell_config_file="$HOME/.zshrc"
else
  echo "Unsupported shell. Please add the alias manually."
  exit 1
fi

# Add alias to the detected shell configuration file
add_alias "$shell_config_file"