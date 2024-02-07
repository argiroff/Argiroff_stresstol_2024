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

#### Summarize DADA2 output as qzv ####

# 16S
SUM_16S_DADA2=$(foreach path,$(PATH_16S),$(path)/denoising_stats_summary.qzv)

$(SUM_16S_DADA2) : code/summarize_dada2.sh\
		$$(dir $$@)dada2/denoising_stats.qza
	code/summarize_dada2.sh $(dir $@)dada2/denoising_stats.qza

# ITS
SUM_ITS_DADA2=$(foreach path,$(PATH_ITS),$(path)/denoising_stats_summary.qzv)

$(SUM_ITS_DADA2) : code/summarize_dada2.sh\
		$$(dir $$@)dada2/denoising_stats.qza
	code/summarize_dada2.sh $(dir $@)dada2/denoising_stats.qza

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
		$$(SEQS_ITS)
	code/merge_repseqs.sh $(SEQS_ITS)

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

#### Assign taxonomy ####

# 16S
TAX_16S=data/qiime2/final_qzas/16S/otu_97_taxonomy/

$(TAX_16S) : code/assign_tax_16s.sh\
		data/qiime2/final_qzas/16S/otu_97/clustered_sequences.qza\
		data/qiime2/final_qzas/taxonomy/16S/silva-138-99-515-806-nb-classifier.qza
	code/assign_tax_16s.sh data/qiime2/final_qzas/16S/otu_97/clustered_sequences.qza data/qiime2/final_qzas/taxonomy/16S/silva-138-99-515-806-nb-classifier.qza

# ITS
TAX_ITS=data/qiime2/final_qzas/ITS/otu_97_taxonomy/

$(TAX_ITS) : code/assign_tax_its.sh\
		data/qiime2/final_qzas/ITS/otu_97/clustered_sequences.qza\
		data/qiime2/final_qzas/taxonomy/ITS/unite_train/unite_QZAs/unite_ver9_seqs_dynamic_29112022.qza\
		data/qiime2/final_qzas/taxonomy/ITS/unite_train/unite_QZAs/unite_ver9_taxonomy_dynamic_29112022.qza
	code/assign_tax_its.sh data/qiime2/final_qzas/ITS/otu_97/clustered_sequences.qza data/qiime2/final_qzas/taxonomy/ITS/unite_train/unite_QZAs/unite_ver9_seqs_dynamic_29112022.qza data/qiime2/final_qzas/taxonomy/ITS/unite_train/unite_QZAs/unite_ver9_taxonomy_dynamic_29112022.qza

#### Full QIIME2 rules ####

# 16S

qiime2_16s : $(MANIFEST_16S_OUT) $(IMPORT_16S_OUT) $(SUM_16S_OUT)\
	$(TRIM_16S_OUT) $(SUM_16S_TRIM) $(DADA2_16S) $(SUM_16S_DADA2)\
	$(MERGE_TAB_16S) $(MERGE_SEQS_16S) $(OTU_97_16S) $(TAX_16S)

# ITS
qiime2_its : $(MANIFEST_ITS_OUT) $(IMPORT_ITS_OUT) $(SUM_ITS_OUT)\
	$(TRIM_ITS_OUT) $(SUM_ITS_TRIM) $(DADA2_ITS) $(SUM_ITS_DADA2)\
	$(MERGE_TAB_ITS) $(MERGE_SEQS_ITS) $(OTU_97_ITS) $(TAX_ITS)

#### Format sequence metadata, 16S ####

# 16S, BC
METADATA_16S_BC=data/processed/seq_data/16S/metadata_working/metadata_16s_bc.txt
METADATA_16S_BC_PRE1=$(wildcard data/metadata/BC/16S/*.csv)
METADATA_16S_BC_PRE2=$(wildcard data/metadata/BC/16S/*.tsv)
METADATA_16S_BC_PRE3=data/metadata/BC/metadata_for_host_spp.txt

$(METADATA_16S_BC) : code/format_16s_bc_metadata.R\
		$$(METADATA_16S_BC_PRE1)\
		$$(METADATA_16S_BC_PRE2)\
		$$(METADATA_16S_BC_PRE3)
	code/format_16s_bc_metadata.R $(METADATA_16S_BC_PRE1) $(METADATA_16S_BC_PRE2) $(METADATA_16S_BC_PRE3) $@

# 16S, BOARD
METADATA_16S_BOARD=data/processed/seq_data/16S/metadata_working/metadata_16s_board.txt
METADATA_16S_BOARD_PRE=data/metadata/BOARD/BOARD_metadata_SraRunTable.txt

$(METADATA_16S_BOARD) : code/format_16s_board_metadata.R\
		$$(METADATA_16S_BOARD_PRE)
	code/format_16s_board_metadata.R $(METADATA_16S_BOARD_PRE) $@

# 16S, DAVIS
METADATA_16S_DAVIS=data/processed/seq_data/16S/metadata_working/metadata_16s_davis.txt

METADATA_16S_DAVIS_PRE1=$(wildcard data/qiime2/16S/DAVIS_*/manifest.txt)
METADATA_16S_DAVIS_PRE2=$(wildcard data/metadata/DAVIS/*.txt)

$(METADATA_16S_DAVIS) : code/format_16s_davis_metadata.R\
		$$(METADATA_16S_DAVIS_PRE1)\
		$$(METADATA_16S_DAVIS_PRE2)
	code/format_16s_davis_metadata.R $(METADATA_16S_DAVIS_PRE1) $(METADATA_16S_DAVIS_PRE2) $@

# 16S full
METADATA_16S=data/processed/seq_data/16S/metadata_working/metadata_16s.txt

$(METADATA_16S) : code/format_metadata_16s.R\
		$$(METADATA_16S_BC)\
		$$(METADATA_16S_BOARD)\
		$$(METADATA_16S_DAVIS)
	code/format_metadata_16s.R $(METADATA_16S_BC) $(METADATA_16S_BOARD) $(METADATA_16S_DAVIS) $@

# metadata_16s : $(METADATA_16S_BC) $(METADATA_16S_BOARD) $(METADATA_16S_DAVIS) $(METADATA_16S)
# metadata_16s : $(METADATA_16S_BC)

#### Final OTU processed tibbles ####

# 16S
FINAL_16S_OTU=data/processed/seq_data/16S/otu_processed/

$(FINAL_16S_OTU) : code/make_otu_tibbles.R\
		$$(wildcard $$(OTU_97_16S)*.qza)\
		$$(wildcard $$(TAX_16S)*.qza)\
		$$(METADATA_16S)
	code/make_otu_tibbles.R $(wildcard $(OTU_97_16S)*.qza) $(wildcard $(TAX_16S)*.qza) $(METADATA_16S) $@

#### ANCOMBC2 input ####

# 16S, split OTU tables and corresponding data
ANCOMBC_IN_16S=data/processed/seq_data/16s/ancombc

$(ANCOMBC_IN_16S) : code/split_otu_for_ancombc.R\
		$$(wildcard $$(FINAL_16S_OTU)*)
	code/split_otu_for_ancombc.R $(wildcard $(FINAL_16S_OTU)*) $@

# 16S, split phyloseq objects
ANCOMBC2_PS_16S_1=$(wildcard $(ANCOMBC_IN_16S)/*)
ANCOMBC2_PS_16S_2=$(foreach path,$(ANCOMBC2_PS_16S_1),$(path)/phyloseq_object.rds)

$(ANCOMBC2_PS_16S_2) : code/ps_for_ancombc.R\
		$$(subst phyloseq_object.rds,metadata_table.txt,$$@)\
		$$(subst phyloseq_object.rds,otu_table.txt,$$@)\
		$$(subst phyloseq_object.rds,representative_sequences.fasta,$$@)\
		$$(subst phyloseq_object.rds,taxonomy_table.txt,$$@)
	code/ps_for_ancombc.R $(subst phyloseq_object.rds,metadata_table.txt,$@) $(subst phyloseq_object.rds,otu_table.txt,$@) $(subst phyloseq_object.rds,representative_sequences.fasta,$@) $(subst phyloseq_object.rds,taxonomy_table.txt,$@) $@

ps_obj : $(ANCOMBC2_PS_16S_2) $(ANCOMBC_IN_16S)
