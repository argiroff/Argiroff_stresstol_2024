#!/usr/bin/env bash

# author: William Argiroff
# inputs: none
# outputs: places SILVA SEED reference alignment into data/references/silva_seed
# Download this version of SILVA reference to help with aligning sequence data
# This is version 138
# Extract to a subdirectory because tgz file contains a README file

wget --directory-prefix=data/references/ --no-clobber https://mothur.s3.us-east-2.amazonaws.com/wiki/silva.seed_v138_1.tgz
mkdir data/references/silva_seed/
tar -xvzf data/references/silva.seed_v138_1.tgz -C data/references/silva_seed/
