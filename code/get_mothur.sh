#!/usr/bin/env bash

# Download mothur from GitHub
wget -P code/ -nc https://github.com/mothur/mothur/releases/download/v1.48.0/Mothur.OSX-10.14.zip

# Unzip
unzip -n -d code/ code/Mothur.OSX-10.14.zip

# Remove zip archive
rm code/Mothur.OSX-10.14.zip