#!/bin/bash

dotfiles_dir=$(dirname "$(pwd)")/.archfiles

# script to be executed AFTER the installation of pacman and aur packages

# check if any rust toolchain is installed, if not download the latest stable version of rust and set as default toolchain
if ! rustup toolchain list | grep -q "stable\|beta\|nightly"; then
	echo "No toolchains found. Setting up stable as default..."
	rustup default stable
else
	echo "Toolchain already exists. Skipping."
fi
