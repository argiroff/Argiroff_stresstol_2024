.SECONDARY:
.SECONDEXPANSION:
print-% :
	@echo '$*=$($*)'

# Rule
# target : prerequisite1 prerequisite2 prerequisite3
# (tab)recipe (and other arguments that are passed to the BASH[or other] script)

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
		$$(subst otu_97/,merged_table.qza,$$@)\
		$$(subst otu_97/,merged_representative_sequences.qza,$$@)
	code/cluster_otu_97.sh $(subst otu_97/,merged_table.qza,$@) $(subst otu_97/,merged_representative_sequences.qza,$@)

#ITS
OTU_97_ITS=data/qiime2/final_qzas/ITS/otu_97/

$(OTU_97_ITS) : code/cluster_otu_97.sh\
		$$(subst otu_97/,merged_table.qza,$$@)\
		$$(subst otu_97/,merged_representative_sequences.qza,$$@)
	code/cluster_otu_97.sh $(subst otu_97/,merged_table.qza,$@) $(subst otu_97/,merged_representative_sequences.qza,$@)

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

assign_tax : $(MERGE_TAB_16S) $(MERGE_SEQS_16S) $(OTU_97_16S)\
$(MERGE_TAB_ITS) $(MERGE_SEQS_ITS) $(OTU_97_ITS) $(TAX_ITS)#$(TAX_16S) 

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
METADATA_BOARD_PRE=data/metadata/BOARD/BOARD_metadata_SraRunTable.txt

$(METADATA_16S_BOARD) : code/format_16s_board_metadata.R\
		$$(METADATA_BOARD_PRE)
	code/format_16s_board_metadata.R $(METADATA_BOARD_PRE) $@

# 16S, DAVIS
METADATA_16S_DAVIS=data/processed/seq_data/16S/metadata_working/metadata_16s_davis.txt
METADATA_16S_DAVIS_PRE1=$(wildcard data/qiime2/16S/DAVIS_*/manifest.txt)
METADATA_DAVIS_PRE2=$(wildcard data/metadata/DAVIS/*.txt)

$(METADATA_16S_DAVIS) : code/format_16s_davis_metadata.R\
		$$(METADATA_16S_DAVIS_PRE1)\
		$$(METADATA_DAVIS_PRE2)
	code/format_16s_davis_metadata.R $(METADATA_16S_DAVIS_PRE1) $(METADATA_DAVIS_PRE2) $@

# 16S full
METADATA_16S=data/processed/seq_data/16S/metadata_working/metadata_16s.txt

$(METADATA_16S) : code/format_metadata.R\
		$$(METADATA_16S_BC)\
		$$(METADATA_16S_BOARD)\
		$$(METADATA_16S_DAVIS)
	code/format_metadata.R $(METADATA_16S_BC) $(METADATA_16S_BOARD) $(METADATA_16S_DAVIS) $@

#### Format sequence metadata, ITS ####

# ITS, BC
METADATA_ITS_BC=data/processed/seq_data/ITS/metadata_working/metadata_its_bc.txt # target
METADATA_ITS_BC_PRE1=$(wildcard data/metadata/BC/ITS/*.csv)
METADATA_ITS_BC_PRE2=$(wildcard data/metadata/BC/ITS/*.tsv)
METADATA_ITS_BC_PRE3=data/metadata/BC/metadata_for_host_spp.txt

$(METADATA_ITS_BC) : code/format_its_bc_metadata.R\
		$$(METADATA_ITS_BC_PRE1)\
		$$(METADATA_ITS_BC_PRE2)\
		$$(METADATA_ITS_BC_PRE3)
	code/format_its_bc_metadata.R $(METADATA_ITS_BC_PRE1) $(METADATA_ITS_BC_PRE2) $(METADATA_ITS_BC_PRE3) $@

# ITS, BOARD
METADATA_ITS_BOARD=data/processed/seq_data/ITS/metadata_working/metadata_its_board.txt

$(METADATA_ITS_BOARD) : code/format_its_board_metadata.R\
		$$(METADATA_BOARD_PRE)
	code/format_its_board_metadata.R $(METADATA_BOARD_PRE) $@

# ITS, DAVIS
METADATA_ITS_DAVIS=data/processed/seq_data/ITS/metadata_working/metadata_its_davis.txt
METADATA_ITS_DAVIS_PRE1=$(wildcard data/qiime2/ITS/DAVIS_*/manifest.txt)

$(METADATA_ITS_DAVIS) : code/format_its_davis_metadata.R\
		$$(METADATA_ITS_DAVIS_PRE1)\
		$$(METADATA_DAVIS_PRE2)
	code/format_its_davis_metadata.R $(METADATA_ITS_DAVIS_PRE1) $(METADATA_DAVIS_PRE2) $@

# ITS full
METADATA_ITS=data/processed/seq_data/ITS/metadata_working/metadata_its.txt

$(METADATA_ITS) : code/format_metadata.R\
		$$(METADATA_ITS_BC)\
		$$(METADATA_ITS_BOARD)\
		$$(METADATA_ITS_DAVIS)
	code/format_metadata.R $(METADATA_ITS_BC) $(METADATA_ITS_BOARD) $(METADATA_ITS_DAVIS) $@

#### Final phyloseq objects ####

# 16S, phyloseq untrimmed
PS_16S_UNTRIMMED=data/processed/seq_data/16S/otu_processed/ps_untrimmed.rds

$(PS_16S_UNTRIMMED) : code/make_16s_ps_untrimmed.R\
		$$(wildcard $$(OTU_97_16S)*.qza)\
		$$(wildcard $$(TAX_16S)*.qza)\
		$$(METADATA_16S)
	code/make_16s_ps_untrimmed.R $(wildcard $(OTU_97_16S)*.qza) $(wildcard $(TAX_16S)*.qza) $(METADATA_16S) $@

# 16S, phyloseq trimmed
PS_16S_TRIMMED=data/processed/seq_data/16S/otu_processed/ps_trimmed.rds

$(PS_16S_TRIMMED) : code/make_16s_ps_trimmed.R\
		$$(PS_16S_UNTRIMMED)
	code/make_16s_ps_trimmed.R $(PS_16S_UNTRIMMED) $@

# ITS, phyloseq untrimmed
PS_ITS_UNTRIMMED=data/processed/seq_data/ITS/otu_processed/ps_untrimmed.rds

$(PS_ITS_UNTRIMMED) : code/make_its_ps_untrimmed.R\
		$$(wildcard $$(OTU_97_ITS)*.qza)\
		$$(wildcard $$(TAX_ITS)*.qza)\
		$$(METADATA_ITS)
	code/make_its_ps_untrimmed.R $(wildcard $(OTU_97_ITS)*.qza) $(wildcard $(TAX_ITS)*.qza) $(METADATA_ITS) $@

# ITS, phyloseq trimmed
PS_ITS_TRIMMED=data/processed/seq_data/ITS/otu_processed/ps_trimmed.rds

$(PS_ITS_TRIMMED) : code/make_its_ps_trimmed.R\
		$$(PS_ITS_UNTRIMMED)
	code/make_its_ps_trimmed.R $(PS_ITS_UNTRIMMED) $@

#### Final OTU tibbles ####

# 16S, OTU
FINAL_16S_OTU=data/processed/seq_data/16S/otu_processed/otu_table.txt

$(FINAL_16S_OTU) : code/get_otu_tibble.R\
		$$(PS_16S_TRIMMED)
	code/get_otu_tibble.R $(PS_16S_TRIMMED) $@

# ITS, OTU
FINAL_ITS_OTU=data/processed/seq_data/ITS/otu_processed/otu_table.txt

$(FINAL_ITS_OTU) : code/get_otu_tibble.R\
		$$(PS_ITS_TRIMMED)
	code/get_otu_tibble.R $(PS_ITS_TRIMMED) $@

#### Final metadata tibbles ####

# 16S, metadata
FINAL_16S_META=data/processed/seq_data/16S/otu_processed/metadata_table.txt

$(FINAL_16S_META) : code/get_metadata_tibble.R\
		$$(PS_16S_TRIMMED)\
		$$(FINAL_16S_OTU)
	code/get_metadata_tibble.R $(PS_16S_TRIMMED) $(FINAL_16S_OTU) $@

# ITS, metadata
FINAL_ITS_META=data/processed/seq_data/ITS/otu_processed/metadata_table.txt

$(FINAL_ITS_META) : code/get_metadata_tibble.R\
		$$(PS_ITS_TRIMMED)\
		$$(FINAL_ITS_OTU)
	code/get_metadata_tibble.R $(PS_ITS_TRIMMED) $(FINAL_ITS_OTU) $@

#### Final representative sequence fasta ####

# 16S, representative sequences
FINAL_16S_REPSEQS=data/processed/seq_data/16S/otu_processed/representative_sequences.fasta

$(FINAL_16S_REPSEQS) : code/get_repseqs_fasta.R\
		$$(PS_16S_TRIMMED)\
		$$(FINAL_16S_OTU)
	code/get_repseqs_fasta.R $(PS_16S_TRIMMED) $(FINAL_16S_OTU) $@

# ITS, representative sequences
FINAL_ITS_REPSEQS=data/processed/seq_data/ITS/otu_processed/representative_sequences.fasta

$(FINAL_ITS_REPSEQS) : code/get_repseqs_fasta.R\
		$$(PS_ITS_TRIMMED)\
		$$(FINAL_ITS_OTU)
	code/get_repseqs_fasta.R $(PS_ITS_TRIMMED) $(FINAL_ITS_OTU) $@

#### Final taxonomy tibbles ####

# 16S, taxonomy
FINAL_16S_TAX=data/processed/seq_data/16S/otu_processed/taxonomy_table.txt

$(FINAL_16S_TAX) : code/get_taxonomy_tibble.R\
		$$(PS_16S_TRIMMED)\
		$$(FINAL_16S_OTU)
	code/get_taxonomy_tibble.R $(PS_16S_TRIMMED) $(FINAL_16S_OTU) $@

# ITS, taxonomy
FINAL_ITS_TAX=data/processed/seq_data/ITS/otu_processed/taxonomy_table.txt

$(FINAL_ITS_TAX) : code/get_taxonomy_tibble.R\
		$$(PS_ITS_TRIMMED)\
		$$(FINAL_ITS_OTU)
	code/get_taxonomy_tibble.R $(PS_ITS_TRIMMED) $(FINAL_ITS_OTU) $@

#### Final sequence summary tibbles ####

# 16S sequence summary
FINAL_16S_SUM=data/processed/seq_data/16S/otu_processed/sequence_summary.txt

$(FINAL_16S_SUM) : code/get_seq_summary_tibble.R\
		$$(PS_16S_UNTRIMMED)\
		$$(PS_16S_TRIMMED)
	code/get_seq_summary_tibble.R $(PS_16S_UNTRIMMED) $(PS_16S_TRIMMED) $@

# ITS sequence summary
FINAL_ITS_SUM=data/processed/seq_data/ITS/otu_processed/sequence_summary.txt

$(FINAL_ITS_SUM) : code/get_seq_summary_tibble.R\
		$$(PS_ITS_UNTRIMMED)\
		$$(PS_ITS_TRIMMED)
	code/get_seq_summary_tibble.R $(PS_ITS_UNTRIMMED) $(PS_ITS_TRIMMED) $@

#### Final table rules ####

# 16S
otu_16s : $(METADATA_16S_BC) $(METADATA_16S_BOARD) $(METADATA_16S_DAVIS) $(METADATA_16S)\
$(PS_16S_UNTRIMMED) $(PS_16S_TRIMMED) $(FINAL_16S_OTU) $(FINAL_16S_META)\
$(FINAL_16S_REPSEQS) $(FINAL_16S_TAX) $(FINAL_16S_SUM)

# ITS
otu_its : $(METADATA_ITS_BC) $(METADATA_ITS_BOARD) $(METADATA_ITS_DAVIS) $(METADATA_ITS)\
$(PS_ITS_UNTRIMMED) $(PS_ITS_TRIMMED) $(FINAL_ITS_OTU) $(FINAL_ITS_META)\
$(FINAL_ITS_REPSEQS) $(FINAL_ITS_TAX) $(FINAL_ITS_SUM)

### ANCOMBC2 input ####

# 16S, ANCOMBC phyloseq inputs
ANCOMBC_16S_IN_NAMES=bc_re_2018 bc_re_2019 bc_rh_2018 bc_rh_2019\
board_bs board_re board_rh davis_bs_summer davis_bs_winter davis_rh_summer\
davis_rh_winter davis_bs_control davis_bs_drought davis_rh_control\
davis_rh_drought location_bs location_re location_rh

ANCOMBC_16S_IN_PATH=$(foreach path,$(ANCOMBC_16S_IN_NAMES),data/processed/seq_data/16S/ancombc/$(path))
ANCOMBC_16S_IN=$(foreach path,$(ANCOMBC_16S_IN_PATH),$(path)_ps.rds)

$(ANCOMBC_16S_IN) : code/get_16s_ps_for_ancombc.R\
		$$(FINAL_16S_META)\
		$$(FINAL_16S_OTU)\
		$$(FINAL_16S_REPSEQS)\
		$$(FINAL_16S_TAX)
	code/get_16s_ps_for_ancombc.R $(FINAL_16S_META) $(FINAL_16S_OTU) $(FINAL_16S_REPSEQS) $(FINAL_16S_TAX) $@

# ITS, ANCOMBC phyloseq inputs
ANCOMBC_ITS_IN_NAMES=bc_re_2018 bc_re_2019 bc_rh_2018 bc_rh_2019\
board_bs board_re board_rh davis_bs_summer davis_bs_winter davis_re_summer\
davis_re_winter davis_rh_summer davis_rh_winter davis_bs_control davis_bs_drought\
davis_re_control davis_re_drought davis_rh_control davis_rh_drought\
location_bs location_re location_rh

ANCOMBC_ITS_IN_PATH=$(foreach path,$(ANCOMBC_ITS_IN_NAMES),data/processed/seq_data/ITS/ancombc/$(path))
ANCOMBC_ITS_IN=$(foreach path,$(ANCOMBC_ITS_IN_PATH),$(path)_ps.rds)

$(ANCOMBC_ITS_IN) : code/get_its_ps_for_ancombc.R\
		$$(FINAL_ITS_META)\
		$$(FINAL_ITS_OTU)\
		$$(FINAL_ITS_REPSEQS)\
		$$(FINAL_ITS_TAX)
	code/get_its_ps_for_ancombc.R $(FINAL_ITS_META) $(FINAL_ITS_OTU) $(FINAL_ITS_REPSEQS) $(FINAL_ITS_TAX) $@

#### Run ANCOMBC2 ####

## Run on CADES HPC ##



#### SPIEC-EASI input ####

# Combined 16S, ITS OTU table
COMB_16S_ITS_OTU=data/processed/seq_data/spieceasi/comb_16s_its_otu.txt

$(COMB_16S_ITS_OTU) : code/get_combined_16s_its_otu_table.R\
		$$(FINAL_16S_META)\
		$$(FINAL_ITS_META)\
		$$(FINAL_16S_OTU)\
		$$(FINAL_ITS_OTU)
	code/get_combined_16s_its_otu_table.R $(FINAL_16S_META) $(FINAL_ITS_META) $(FINAL_16S_OTU) $(FINAL_ITS_OTU) $@

SPIECEASI_IN_NAMES=full_bs full_re full_rh bc_re bc_rh\
board_bs board_re board_rh davis_bs davis_re davis_rh

SPIECEASI_IN_PATH=$(foreach path,$(SPIECEASI_IN_NAMES),data/processed/seq_data/spieceasi/$(path))

# 16S inputs
SPIECEASI_16S_IN=$(foreach path,$(SPIECEASI_IN_PATH),$(path)_16s_input.rds)

$(SPIECEASI_16S_IN) : code/get_input_for_spieceasi.R\
		$$(COMB_16S_ITS_OTU)
	code/get_input_for_spieceasi.R $(COMB_16S_ITS_OTU) $@

# ITS inputs
SPIECEASI_ITS_IN=$(foreach path,$(SPIECEASI_IN_PATH),$(path)_its_input.rds)

$(SPIECEASI_ITS_IN) : code/get_input_for_spieceasi.R\
		$$(COMB_16S_ITS_OTU)
	code/get_input_for_spieceasi.R $(COMB_16S_ITS_OTU) $@

#### Run SPIEC-EASI ####



#### BLASTN against culture collection ####


#### BLASTN against sequenced genomes ####


#### Summarize ANCOMBC ####

# Extract 16S OTU responses
ANCOMBC_16S_EXT=$(foreach path,$(ANCOMBC_16S_IN_PATH),$(path)_ancombc_results.txt)

$(ANCOMBC_16S_EXT) : code/extract_ancombc_results.R\
		$$(subst .txt,.rds,$$@)
	code/extract_ancombc_results.R $(subst .txt,.rds,$@) $@

# Extract ITS OTU responses
ANCOMBC_ITS_EXT=$(foreach path,$(ANCOMBC_ITS_IN_PATH),$(path)_ancombc_results.txt)

$(ANCOMBC_ITS_EXT) : code/extract_ancombc_results.R\
		$$(subst .txt,.rds,$$@)
	code/extract_ancombc_results.R $(subst .txt,.rds,$@) $@

# Combine ANCOMBC results, 16S
ANCOMBC_16S_COMB=data/processed/seq_data/16S/ancombc/ancombc_results.txt

$(ANCOMBC_16S_COMB) : code/combine_ancombc_results.R\
		$$(ANCOMBC_16S_EXT)
	code/combine_ancombc_results.R $(ANCOMBC_16S_EXT) $@

#  Combine ANCOMBC results, ITS
ANCOMBC_ITS_COMB=data/processed/seq_data/ITS/ancombc/ancombc_results.txt

$(ANCOMBC_ITS_COMB) : code/combine_ancombc_results.R\
		$$(ANCOMBC_ITS_EXT)
	code/combine_ancombc_results.R $(ANCOMBC_ITS_EXT) $@

# Volcano plots, 16S
VOLCANO_16S_PATH=$(subst data/processed/seq_data/16S/ancombc,results,$(ANCOMBC_16S_EXT))
VOLCANO_16S=$(subst ancombc_results.txt,16s_volcano_plot.pdf,$(VOLCANO_16S_PATH))

$(VOLCANO_16S) : code/make_volcano_plots.R\
		$$(subst 16s_volcano_plot.pdf,ancombc_results.txt,$$(subst results,data/processed/seq_data/ITS/ancombc, $$@))
	code/make_volcano_plots.R $(subst 16s_volcano_plot.pdf,ancombc_results.txt,$(subst results,data/processed/seq_data/16S/ancombc, $@)) $@

# Volcano plots, ITS
VOLCANO_ITS_PATH=$(subst data/processed/seq_data/ITS/ancombc,results,$(ANCOMBC_ITS_EXT))
VOLCANO_ITS=$(subst ancombc_results.txt,its_volcano_plot.pdf,$(VOLCANO_ITS_PATH))

$(VOLCANO_ITS) : code/make_volcano_plots.R\
		$$(subst its_volcano_plot.pdf,ancombc_results.txt,$$(subst results,data/processed/seq_data/ITS/ancombc, $$@))
	code/make_volcano_plots.R $(subst its_volcano_plot.pdf,ancombc_results.txt,$(subst results,data/processed/seq_data/ITS/ancombc, $@)) $@

volcano : $(ANCOMBC_16S_COMB) $(ANCOMBC_ITS_COMB) $(VOLCANO_16S) $(VOLCANO_ITS)


# Summarise ANCOMBC results

TEST1=$(subst volcano_plot.pdf,ancombc_results.txt,$(subst results,data/processed/seq_data/ITS/ancombc, $(VOLCANO_ITS)))
ancombc : $(ANCOMBC_16S_EXT) $(ANCOMBC_ITS_EXT) $(ANCOMBC_16S_COMB) $(ANCOMBC_ITS_COMB)








# spieceasi_in : $(COMB_16S_ITS_OTU) $(SPIECEASI_16S_IN) $(SPIECEASI_ITS_IN)



# ancombc : $(ANCOMBC_16S_IN) $(ANCOMBC_ITS_IN)

#

# # 16S, split OTU tables and corresponding data
# ANCOMBC_IN_16S=data/processed/seq_data/16s/ancombc_in

# $(ANCOMBC_IN_16S) : code/split_16s_otu_for_ancombc.R\
# 		$$(wildcard $$(FINAL_16S_OTU)*)
# 	code/split_16s_otu_for_ancombc.R $(wildcard $(FINAL_16S_OTU)*) $@

# # 16S, split phyloseq objects
# ANCOMBC_PS_16S_1=$(wildcard $(ANCOMBC_IN_16S)/*)
# ANCOMBC_PS_16S_2=$(foreach path,$(ANCOMBC_PS_16S_1),$(path)/phyloseq_object.rds)

# $(ANCOMBC_PS_16S_2) : code/ps_16s_for_ancombc.R\
# 		$$(subst phyloseq_object.rds,metadata_table.txt,$$@)\
# 		$$(subst phyloseq_object.rds,otu_table.txt,$$@)\
# 		$$(subst phyloseq_object.rds,representative_sequences.fasta,$$@)\
# 		$$(subst phyloseq_object.rds,taxonomy_table.txt,$$@)
# 	code/ps_16s_for_ancombc.R $(subst phyloseq_object.rds,metadata_table.txt,$@) $(subst phyloseq_object.rds,otu_table.txt,$@) $(subst phyloseq_object.rds,representative_sequences.fasta,$@) $(subst phyloseq_object.rds,taxonomy_table.txt,$@) $@

# ps_obj : $(ANCOMBC_IN_16S) $(ANCOMBC_PS_16S_2)

# ps_obj : $(ANCOMBC_PS_16S_2) $(METADATA_16S_BC) $(METADATA_16S_BOARD)\
# 	$(METADATA_16S_DAVIS) $(METADATA_16S) $(FINAL_16S_OTU)\
# 	$(FINAL_16S_OTU) $(ANCOMBC_IN_16S) $(ANCOMBC_PS_16S_2)
