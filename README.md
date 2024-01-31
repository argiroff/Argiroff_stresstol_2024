# Identification of microbial taxa along a stress tolerance-competitive dominance continuum  

**Author:** William Argiroff  

Developed to identify ecologically relevant synthetic communities to test microbial role in Populus stress tolerance.  

Associated an R project with root project directory (`Argiroff_stresstol_2024.Rproj`)  

### Dependencies:  
* [mothur v 1.48.0](https://github.com/mothur/mothur/releases/tag/v1.48.0) - `code/get_mothur.sh` installs mothur in `code/`  
* `wget`  
* `R`  
* `RStudio`  
* `QIIME2` v2022.8  

### Makefile  

Makefile contains rules to reproduce data analysis pipeline. The rules `qiime2_16s` and `qiime2_its` reproduce the processing of 16S and ITS2 sequences, respectively, up through OTU clustering and taxonomic assignments.  

