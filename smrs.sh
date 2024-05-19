#!/bin/bash
SMOOTHIE_INSTALL_DIRECTORY="$HOME/.local/share/smoothie-rs"
SMOOTHIE_BIN_DIR="$SMOOTHIE_INSTALL_DIRECTORY/smoothie-rs/target/bin"
MAINTAINER="hybridkernel"
SUPPORT_DISC="discord.gg/ctt"
REPO_TESTED="https://github.com/Hzqkii/smoothie-rs.git"
REPO_LATEST="https://github.com/couleur-tweak-tips/smoothie-rs.git"

printf 'This is an unofficial build script, for support please ping %s @ %s\n' $MAINTAINER $SUPPORT_DISC
#Arch
if command -v pacman &> /dev/null; then
  printf 'This script will perform a system uptade, do you wish to continue? (y/n)? '
  read answer

  if [ "$answer" != "${answer#[Yy]}" ] ;then 
      printf 'ok\n'
  else
      exit 1
  fi
  sudo pacman -Syu --needed rustup git base-devel #install rust
  PKGMAN=1
fi

#Debian / Ubuntu
if command -v apt &> /dev/null; then
  sudo apt install curl build-essential
  if ! command -v cargo &> /dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh #Not in debian repos, its in trixie and sid; lmk if it makes its way down
  else
    printf 'cargo is already installed, skipping installation\n'
  fi
  PKGMAN=1
fi 

#fedora
if command -v dnf &> /dev/null; then
  sudo dnf update
  sudo dnf install rustup
  PKGMAN=1
fi

if [ "$PKGMAN" -ne 1 ]; then
  printf 'unsupported distribuition\n'
  exit 1
fi

mkdir $SMOOTHIE_INSTALL_DIRECTORY #Make the smoothie directory in ~/.local/share

if ! test -d $SMOOTHIE_INSTALL_DIRECTORY; then
  printf "unable to create the smoothie fo$HOME/.local/share/smoothie-rs/smoothie-rs/target/binlder at %s\nProlly fucked permissions\n" $SMOOTHIE_INSTALL_DIRECTORY
else 
  echo "Smoothie directory exists."
fi



cd $SMOOTHIE_INSTALL_DIRECTORY/
printf 'What version of smoothie do you want to install?\n 1. Upstream(latest git) (or) 2. Tested Fork(Tested against Linux, is usually behind) '
read answer
if [ "$answer" != "${answer#[2]}" ] ;then 
  printf "Installing tested"
  git clone $REPO_TESTED
else
  printf "Installing latest git"
  git clone $REPO_LATEST
fi

cd smoothie-rs

if ! command -v cargo; then
  printf 'cargo install likely failed, manual intervention is required\n'
  exit 1
fi

cargo build -v 2>&1 | tee ../buildLog.log
if [ $? -ne 0 ]; then
  printf "Build failed, please open a support ticket in %s, and ping %s, DO NOT PING ANYONE ELSE\n" "$SUPPORT_DISC" "$MAINTAINER"
  exit 1
fi

cd target
mkdir bin
if ! test -d "./bin"; then
  printf "unable to make dir bin\n"
  exit 1
fi

echo $SHELL

echo $SMOOTHIE_BIN_DIR

cp "$SMOOTHIE_INSTALL_DIRECTORY/smoothie-rs/target/debug/smoothie-rs" $SMOOTHIE_BIN_DIR

SM_PATH="export PATH=\"\$PATH:$SMOOTHIE_BIN_DIR\""


shell_name=$(basename "$SHELL")

if [ "$shell_name" == "zsh" ]; then
  echo $SM_PATH >> "$HOME/.zshrc"
elif [ "$shell_name" == "bash" ]; then
  echo $SM_PATH >> "$HOME/.bashrc"
elif [ "$shell_name" == "fish" ]; then
  echo $SM_PATH >> "$HOME/.fishrc"
else
  printf "Unsupported Shell, please add %s to your PATH\n" "$SM_PATH"
fi


exit 0
