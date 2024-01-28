.SECONDARY:
.SECONDEXPANSION:
.PHONY: manifest_16s
print-% :
	@echo '$*=$($*)'

# Rule
# target : prerequisite1 prerequisite2 prerequisite3
# (tab)recipe (and other arguments that are passed to the BASH script)

#### Use R to make QIIME2 manifest files ####

# 16S
PATH_16S=$(wildcard data/qiime2/16S/*)
MANIFEST_16S_OUT=$(foreach path,$(PATH_16S),$(path)/manifest.txt)

$(MANIFEST_16S_OUT) : code/get_manifest.R\
				$$(dir $$@)reads/
	code/get_manifest.R $(dir $@)reads/ $@

manifest_16s : $(MANIFEST_16S_OUT)

# ITS
PATH_ITS=$(wildcard data/qiime2/ITS/*)
MANIFEST_ITS_OUT=$(foreach path,$(PATH_ITS),$(path)/manifest.txt)

$(MANIFEST_ITS_OUT) : code/get_manifest.R\
				$$(dir $$@)reads/
	code/get_manifest.R $(dir $@)reads/ $@

#### IMPORT fastq to qza using QIIME2 ####

# 16S
IMPORT_16S_OUT=$(foreach path,$(PATH_16S),$(path)/demux.qza)

$(IMPORT_16S_OUT) : code/import_seqs_to_qza.sh\
				$$(dir $$@)manifest.txt
	code/import_seqs_to_qza.sh $(dir $@)manifest.txt

IMPORT_16S=$(MANIFEST_16S_OUT) $(IMPORT_16S_OUT)
import_16s : $(IMPORT_16S)

# ITS
IMPORT_ITS_OUT=$(foreach path,$(PATH_ITS),$(path)/demux.qza)

$(IMPORT_ITS_OUT) : code/import_seqs_to_qza.sh\
				$$(dir $$@)manifest.txt
	code/import_seqs_to_qza.sh $(dir $@)manifest.txt

IMPORT_ITS=$(MANIFEST_ITS_OUT) $(IMPORT_ITS_OUT)
import_its : $(IMPORT_ITS)











# MANIFEST_16S=$(wildcard data/qiime2/16S/*)
# MANIFEST_16S_OUT=$(foreach path,$(MANIFEST_16S),$(path)/manifest/manifest.txt)
# MANIFEST_ITS=$(wildcard data/qiime2/ITS/*)
# MANIFEST_ITS_OUT=$(foreach path,$(MANIFEST_ITS),$(path)/manifest/manifest.txt)
# MANIFEST_OUT=$(MANIFEST_16S_OUT) $(MANIFEST_ITS_OUT)

# $(MANIFEST_OUT) : code/run_rscript.sh\
# 				code/rscripts/get_manifest.R\

# 	./code/run_rscript.sh code/rscripts/get_manifest.R

# manifest : $(MANIFEST_OUT)

# # ITS
# MANIFEST_ITS=$(wildcard data/qiime2/ITS/*)
# MANIFEST_ITS_OUT=$(foreach path,$(MANIFEST_ITS),$(path)/manifest/manifest.txt)

# $(MANIFEST_ITS_OUT) : code/run_rscript.sh\
# 				code/rscripts/get_manifest.R
# 	./code/run_rscript.sh code/rscripts/get_manifest.R

# manifest_16s : $(MANIFEST_ITS_OUT)

#### QIIME2 import ####


































# IMPORT_INPATH_16S:=$(wildcard data/qiime2/16S/*)
# IMPORT_OUTDIR_16S:=$(subst data/qiime2/16S/,,$(IMPORT_INPATH_16S))
# IMPORT_INFILE_16S:=$(wildcard data/qiime2/16S/*/manifest)/manifest.txt


# $(IMPORT_INFILE_16S) : code/run_rscript.sh\
# 				code/rscripts/get_manifest.R\
# 				data/qiime2/16S/%/manifest/manifest.txt
# 	./code/run_rscript.sh code/rscripts/get_manifest.R

# manifest_16s : $(IMPORT_INFILE_16S)


# manifest_16s : get_manifest.R
# 	get_manifest.R


#### QIIME2 import fastq ####

# Get 16S import input files for QIIME2

# IMPORT_INFILES_16S_2=$(IMPORT_INFILES_16S_1)/manifest.txt

# #IMPORT_INFILES_16S_1:=$(wildcard data/qiime2/manifest_files/16S/*.txt)
# IMPORT_INFILES_16S_2:=$(subst data/qiime2/manifest_files/16S/manifest_,,$(IMPORT_INFILES_16S_1))
# IMPORT_INFILES_16S_3:=$(subst .txt,,$(IMPORT_INFILES_16S_2))

# # Get 16S import output files for QIIME2
# IMPORT_OUTFILES_16S_1:=$(subst .txt,.qza,$(IMPORT_INFILES_16S_1))
# IMPORT_OUTFILES_16S_2:=$(subst manifest_files,import,$(IMPORT_OUTFILES_16S_1))
# IMPORT_OUTFILES_16S_3:=$(subst manifest_,demux_,$(IMPORT_OUTFILES_16S_2))

# Import 16S
# data/qiime2/import/16S/demux_%.qza : 


# $(IMPORT_OUTFILES_16S3) : $$(IMPORT_INFILES_16S) \
# 				code/import_qiime2script.sh
# 	$^ $(IMPORT_INFILES_16S)

# importoutfiles16S : $(IMPORT_OUTFILES_16S3)

# USER_OBJS=$(wildcard $(data/qiime2/manifest_files/16S/)*.txt)
# MANIFEST_SOURCES := $(wildcard $(data/qiime2/manifest_files/16S/)/*.txt)
# SOURCES_16S_TEMP=$(foreach)

# data/qiime2/imported/16S/demux_%.qza : data/qiime2/manifest_files/16S/manifest_%.txt\
# 				code/import_qiime2script.sh
# 	./code/import_qiime2script.sh data/qiime2/manifest_files/16S/manifest_%.txt

# data/qiime2/imported/16S/demux_BC_16S_LE1.qza : data/qiime2/manifest_files/16S/manifest_BC_16S_LE1.txt\
# 				code/import_qiime2script.sh
# 	./code/import_qiime2script.sh data/qiime2/manifest_files/16S/manifest_BC_16S_LE1.txt

# data/qiime2/imported/16S/ : data/qiime2/manifest_files/16S/
# 	./code/import_qiime2script.sh data/qiime2/manifest_files/16S/

# data/references/silva_seed/silva.seed_v138_1.align : code/get_silva_seed.sh
# 	./code/get_silva_seed.sh

