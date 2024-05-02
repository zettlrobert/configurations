#!/usr/bin/env bash

echo "Password required to symlink binaries"

# Ask for the administrator password upfront
echo echo "${password}" | sudo -v

# Capture exit code
exit_code=$?

# Evaluate exit code
if [[ ${exit_code} -eq 0 ]]; then
  echo "Password is correct, proceed"
else
  echo -e "Password is incorrect --> PLEASE RERUN COMMAND"
  exit 1
fi

echo "Fetching newest kitty binaries..."

# https://sw.kovidgoyal.net/kitty/binary/
curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin

# create symlink to make kitty  binary available
if [ ! -f /usr/bin/kitty ]; then
  sudo ln -s $HOME/.local/kitty.app/bin/kitty /usr/bin/kitty
fi

# create symlink to make kitten binary available
if [ ! -f /usr/bin/kitten ]; then
  sudo ln -s $HOME/.local/kitty.app/bin/kitten /usr/bin/kitten 
fi
