# README  

Obtained files from [mothur wiki](https://mothur.org/wiki/silva_reference_files/). These are [SILVA SEED
alignments files from version 138](https://mothur.org/wiki/silva_reference_files/).

Downloaded automatically with:  


```
wget --directory-prefix=data/references/ --no-clobber https://mothur.s3.us-east-2.amazonaws.com/wiki/silva.seed_v138_1.tgz
```  

New directory for extraction and then extracted into silva_seed:  

```
mkdir data/references/silva_seed/
tar -xvzf data/references/silva.seed_v138_1.tgz -C data/references/silva_seed/
```

