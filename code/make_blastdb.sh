#!/usr/bin/env bash

# name: make_blastdb.sh
# author: William Argiroff
# inputs: fasta file that will be BLAST database
# outputs: BLAST database
# notes: expects path(relative to project root)/<FILENAME>.fasta as input

# Get input file
infile=`echo "$1"| sed -E "s/.ndb/.fasta/"`
indir=`echo "$infile" | sed -E "s/\(.*\/\).*/\1/"`

# Make BLAST database
#makeblastdb -in 3328_PMI_isolates_16S.fasta -input_type fasta -dbtype nucl -parse_seqids -out 3328_PMI_isolates_16S
echo "$infile"
echo "$indir"
