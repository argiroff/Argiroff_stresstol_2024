.SECONDARY:
.SECONDEXPANSION:
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

# ITS
IMPORT_ITS_OUT=$(foreach path,$(PATH_ITS),$(path)/demux.qza)

$(IMPORT_ITS_OUT) : code/import_seqs_to_qza.sh\
		$$(dir $$@)manifest.txt
	code/import_seqs_to_qza.sh $(dir $@)manifest.txt

IMPORT_ITS=$(MANIFEST_ITS_OUT) $(IMPORT_ITS_OUT)

#### Summarize imported raw seqs as qzv ####

# 16S
SUM_16S_OUT=$(foreach path,$(PATH_16S),$(path)/demux_summary.qzv)

$(SUM_16S_OUT) : code/summarize_seqs.sh\
		$$(dir $$@)demux.qza
	code/summarize_seqs.sh $(dir $@)demux.qza

# ITS
SUM_ITS_OUT=$(foreach path,$(PATH_ITS),$(path)/demux_summary.qzv)

$(SUM_ITS_OUT) : code/summarize_seqs.sh\
		$$(dir $$@)demux.qza
	code/summarize_seqs.sh $(dir $@)demux.qza

summary_its : $(MANIFEST_ITS_OUT) $(IMPORT_ITS_OUT) $(SUM_ITS_OUT)

#### Trim sequences ####

# 16S, cutadapt
TRIM_16S_OUT=$(foreach path,$(PATH_16S),$(path)/trimmed.qza)

$(TRIM_16S_OUT) : code/cutadapt_16s.sh\
		$$(dir $$@)demux.qza
	code/cutadapt_16s.sh $(dir $@)demux.qza

# ITS, ITSxpress
TRIM_ITS_OUT=$(foreach path,$(PATH_ITS),$(path)/trimmed.qza)

$(TRIM_ITS_OUT) : code/itsxpress_its.sh\
		$$(dir $$@)demux.qza
	code/itsxpress_its.sh $(dir $@)demux.qza

#### Summarize trimmed seqs as qzv ####

# 16S
SUM_16S_TRIM=$(foreach path,$(PATH_16S),$(path)/trimmed_summary.qzv)

$(SUM_16S_TRIM) : code/summarize_trimmed_seqs.sh\
		$$(dir $$@)trimmed.qza
	code/summarize_trimmed_seqs.sh $(dir $@)trimmed.qza

# ITS
SUM_ITS_TRIM=$(foreach path,$(PATH_ITS),$(path)/trimmed_summary.qzv)

$(SUM_ITS_TRIM) : code/summarize_trimmed_seqs.sh\
		$$(dir $$@)trimmed.qza
	code/summarize_trimmed_seqs.sh $(dir $@)trimmed.qza

#### DADA2

# 16S
DADA2_16S=$(foreach path,$(PATH_16S),$(path)/dada2/)

$(DADA2_16S) : code/dada2.sh\
		$$(subst dada2,trimmed.qza,$$@)
	code/dada2.sh $(subst dada2,trimmed.qza,$@)

# ITS
DADA2_ITS=$(foreach path,$(PATH_ITS),$(path)/dada2/)

$(DADA2_ITS) : code/dada2.sh\
		$$(subst dada2,trimmed.qza,$$@)
	code/dada2.sh $(subst dada2,trimmed.qza,$@)

dada2_its : $(MANIFEST_ITS_OUT) $(IMPORT_ITS_OUT) $(SUM_ITS_OUT)\
	$(TRIM_ITS_OUT) $(SUM_ITS_TRIM) $(DADA2_ITS)

#### Summarize DADA2 output as qzv ####

# 16S
SUM_16S_DADA2=$(foreach path,$(PATH_16S),$(path)/denoising_stats_summary.qzv)

$(SUM_16S_DADA2) : code/summarize_dada2.sh\
		$$(dir $$@)dada2/denoising_stats.qza
	code/summarize_dada2.sh $(dir $@)dada2/denoising_stats.qza

# ITS
SUM_DADA2_ITS=$(foreach path,$(PATH_ITS),$(path)/denoising_stats_summary.qzv)

#### Merge ASV tables ####

# 16S
TAB_16S=$(wildcard data/qiime2/16S/*/dada2/table.qza)
MERGE_TAB_16S=data/qiime2/final_qzas/16S/merged_table.qza

$(MERGE_TAB_16S) : code/merge_tables.sh\
		$$(TAB_16S)
	code/merge_tables.sh $(TAB_16S)

#ITS
TAB_ITS=$(wildcard data/qiime2/ITS/*/dada2/table.qza)
MERGE_TAB_ITS=data/qiime2/final_qzas/ITS/merged_table.qza

$(MERGE_TAB_ITS) : code/merge_tables.sh\
		$$(TAB_ITS)
	code/merge_tables.sh $(TAB_ITS)

#merge_tab_its : $(DADA2_ITS) $(SUM_ITS_DADA2) $(MERGE_TAB_ITS)
merge_tab_its : $(MERGE_TAB_ITS)

#### Merge ASV representative sequences ####

# 16S
SEQS_16S=$(wildcard data/qiime2/16S/*/dada2/representative_sequences.qza)
MERGE_SEQS_16S=data/qiime2/final_qzas/16S/merged_representative_sequences.qza

$(MERGE_SEQS_16S) : code/merge_repseqs.sh\
		$$(SEQS_16S)
	code/merge_repseqs.sh $(SEQS_16S)

#ITS
SEQS_ITS=$(wildcard data/qiime2/ITS/*/dada2/representative_sequences.qza)
MERGE_SEQS_ITS=data/qiime2/final_qzas/ITS/merged_representative_sequences.qza

$(MERGE_SEQS_ITS) : code/merge_repseqs.sh\
		$$(MERGE_SEQS_ITS)
	code/merge_repseqs.sh $(MERGE_SEQS_ITS)

#merge_seqs_its : $(DADA2_ITS) $(SUM_ITS_DADA2) $(MERGE_SEQS_ITS)
merge_seqs_its : $(MERGE_SEQS_ITS)

#### Cluster 97% OTUs, table ####

# 16S
OTU_97_16S=data/qiime2/final_qzas/16S/otu_97/

$(OTU_97_16S) : code/cluster_otu_97.sh\
		$$(subst otu_97,merged_table.qza,$$@)\
		$$(subst otu_97,merged_representative_sequences.qza,$$@)
	code/cluster_otu_97.sh $(subst otu_97,merged_table.qza,$@) $(subst otu_97,merged_representative_sequences.qza,$@)

#ITS
OTU_97_ITS=data/qiime2/final_qzas/ITS/otu_97/

$(OTU_97_ITS) : code/cluster_otu_97.sh\
		$$(subst otu_97,merged_table.qza,$$@)\
		$$(subst otu_97,merged_representative_sequences.qza,$$@)
	code/cluster_otu_97.sh $(subst otu_97,merged_table.qza,$@) $(subst otu_97,merged_representative_sequences.qza,$@)

otu_97_its : $(OTU_97_ITS)

#### Assign taxonomy ####

# 16S
TAX_16S=data/qiime2/final_qzas/16S/otu_97_taxonomy/

$(TAX_16S) : code/assign_tax_16s.sh\
		data/qiime2/final_qzas/16S/otu_97/clustered_sequences.qza\
		data/qiime2/final_qzas/taxonomy/16S/silva-138-99-515-806-nb-classifier.qza
	code/assign_tax_16s.sh data/qiime2/final_qzas/16S/otu_97/clustered_sequences.qza data/qiime2/final_qzas/taxonomy/16S/silva-138-99-515-806-nb-classifier.qza

# ITS

#### Full QIIME2 rules ####

# 16S

qiime2_16s : $(MANIFEST_16S_OUT) $(IMPORT_16S_OUT) $(SUM_16S_OUT)\
	$(TRIM_16S_OUT) $(SUM_16S_TRIM) $(DADA2_16S) $(SUM_16S_DADA2)\
	$(MERGE_TAB_16S) $(MERGE_SEQS_16S) $(OTU_97_16S) $(TAX_16S)

# ITS
