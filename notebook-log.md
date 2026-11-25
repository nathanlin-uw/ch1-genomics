This is the notebook log for chapter 1, the genomics portion, of my Master's thesis.

### Setting up this GitHub Repo ###
I first created this repository on the GitHub website, initializing it with a README and the MIT license. 

In the terminal, I used `git clone https://github.com/nathanlin-uw/ch1-genomics.git` to create a copy of the repository on my computer, then updated the README, created this log, and started a .gitignore.

To push changes back to the online repository, I use `git add .`, `git status`, `git commit -m "Commit message"`, and `git push`.

### Setting up folder system & NCBI genomes review ###
To start, I made a folder for scripts, a folder for script inputs, and a folder for genomes downloaded from NCBI, using `mkdir ncbi-genomes`, `mkdir scripts`, etc. I added a README to each folder. Later on, I would put ncbi-genomes/ and other related folders in a data/ folder.

I also added a folder, info/, for background information. Into this folder I placed ncbi-ixodid-genomes-v1-20261105.pdf, my review of genomes available on NCBI, where I gathered information on the assemblies, located their corresponding publications, and arranged them based on assembly quality. Using this information, I created all-ncbi-genomes-20261105.csv, which contains the accession number, the name I assigned, whether an annotation is available, and the genome quality -- this is found in script-inputs/. I also created a folder called old-versions in script-inputs/ and info/.

### Setting up Conda ###
The Conda package and environment manager is used to download many of the packages we will need. 

I installed miniconda3 to my home/ntlin/ (aka ~/) directory, running through the installer and choosing to initialize Conda automatically (this is very important in order to make the conda command available after the installation!!), with `bash Miniconda3-latest-Linux-x86_64.sh`. After reopening the terminal or using the refresh command `source ~/.bashrc`, the `conda` command is now available! I used `conda config --auto_activate_base false` to make it so that I don't automatically go into the base environment on startup.

I used `conda info` to learn that my Conda is version 26.9.3, my Python is version 3.14.8.final.0, and the distribution I used was Miniconda3 py314_26.9.3-0 (sh, linux-64). The next day, I updated Conda to 26.9.4 with `conda self update`.

## Genomes from NCBI ## 

### Downloading genomes from NCBI ###
I created a script, 01-ncbi-downloading.sh, for downloading a set of NCBI genomes (and protein-coding genes, if an annotation is available), for a specified assembly quality. I intend to 1) retrieve the genome sequences for each assembly, 2) retrieve a list of protein-coding genes for assemblies with high-quality annotations to concatenate for a "full genes list", and 3) retrieve whatever is necessary to run OrthoFinder on the same assemblies with high-quality annotations. My goal is to assess the quality of each assembly's annotation before using the annotation's protein sequences in OrthoFinder -- this script downloads the genome files and available annotation files of all of our assemblies, in preparation for quality assessment and later discarding of low-quality annotations.

Script verbalized: This script takes a "high/med/low" argument when run. It first validates the input, then accesses the csv file containing the accession numbers, annotation information, and quality details of the NCBI genome assemblies. I would first filter to only have assemblies of the specified quality, then for each of the resulting entries, I would check whether or not there is an annotation. For assemblies with annotations, I would download the genome file, gff3 annotation file, cds file, and protein sequences file. For assemblies without annotations, I would download only the genome file. 

My notes for thinking through and writing this script are below: 
- OrthoFinder input (https://github.com/davidemms/OrthoFinder): 
	- OrthoFinder takes a directory of protein sequence FASTA files
	- One of its outputs is a FASTA for each orthogroup, containing the sequences of each gene in that orthogroup.

- Captus input (https://edgardomortiz.github.io/captus.docs/assembly/extract/preparation/): 
	- You can have multiple sequences for a single locus! For OrthoFinder output, can we then consider each orthogroup to be one locus, and include the sequences identified for that orthogroup each as individual references? Each ID line of the FASTA would then use the naming format >{Sequence ID}-{Locus} [{optional description}].
	- Coding sequences can either be amino acids or nucleotides. 

- Bash scripting: 
	- Script arguments: I only need one positional argument for this script, which I would access with `"$1"`. I'd validate this later, by iterating through each of the quality levels ("high"/"med"/"low"). If none of those words match the argument given, it'll throw an error. 
	- To extract information from .csv's, I would use `while IFS=$',' read -r accession_number assembly_name annotation_info assembly_quality; do {filter then iterate through contents, download NCBI assets}; done < ../all-ncbi-genomes-20261105.csv`
	- For a line in the .csv, if statement for whether there is an annotation or not, then pull out the accession number and run the ncbi datasets command to download its files.
	- For loops in Bash: `for {item or file} in {array or directory}; do {whatever}; done;`. 
	- If statements in Bash: `if [[ $annotation_info = "ncbi-ann" ]]; then {download genome and annotation files}; else {download genome files}; fi`

- NCBI datasets command line interface:
	- This script depends on the ncbi-datasets-cli package, version 18.41.1. I installed it using Conda, with `conda install conda-forge::ncbi-datasets-cli`
	- I can use the following command: `datasets download genome accession "${accession_number}" --filename "${assembly_name}" --include genome,gff3,cds,protein`
	- Each assembly is downloaded as a zip file, which unzips to an archive containing the assembly's files, with the folder structure ncbi_dataset/data/{accession number}/. I will need to extract, rename, and clean up these files in the script. When renaming the files like protein.faa, I'll just attach the assembly name in front. I use parameter expansion for this -- in order to pull out the file name, which is the very last part of the path, I can access it with `"${file##*/}"`.

To run the script, in the scripts/ folder and with ncbi-datasets-cli in the active Conda environment, I used the commands `bash 01-ncbi-downloading.sh high`, `bash 01-ncbi-downloading.sh med`, and `bash 01-ncbi-downloading.sh low`. The downloads were all saved to data/ncbi-genomes/, in their respective high-quality/, med-quality/, and low-quality/ subfolders. I used `screen` on the server, with `screen -S nl-genomes-downloading-1`, activating the Conda env and starting the download for one quality batch, Ctrl+A+D to exit the screen, and `screen -r nl-genomes-downloading-1` with `exit` to reattach and close the screen once the downloads finished.

The first time around, the high quality genomes used 61G of storage space, the med quality genomes used 26G, and the low quality genomes used 39G, for a total of 125G. There should have been 24 assemblies for which annotations are available (19 high, 4 med, 1 low), although only 10 of the 19 high quality assemblies actually had cds/protein files downloaded. I think I may need to swap the assemblies used from the GCA to the GCF versions (GenBank by submitter vs NCBI owned curated copy) so that I can actually get the assembly with it. The assemblies missing annotations are those for A. mixtum, A. americanum (Luecke), A. maculatum, D. albipictus, D. andersoni, D. variabilis, Ha. longicornis (Moustafa), I. scapularis, and R. microplus (Tidwell). I'll grab the accessions for these RefSeq assemblies, add them to the info PDF, and add them to the script input csv as a new set of assemblies of "legacy-for-annotation" quality. 

The second time, with the inclusion of the legacy assemblies, I had 24/24 annotations. The high quality genomes used __G of storage space, ...


### Quality assessment of annotations ###

First, I compiled all of the CDS for assemblies with annotations into a new folder called ncbi-annotated-cds/. In data/ncbi-genomes/, I used the command `shopt -s globstar nullglob; for item in ./**; do if [[ "${item: -20}" = "cds_from_genomic.fna" ]]; then echo "${item}"; cp "${item}" ../ncbi-annotated-cds/; fi; done` to iterate through each file in its subdirectories and copy every file ending in cds_from_genomic.fna into ncbi-annotated-cds/. I then did the same thing for protein sequences with `shopt -s globstar nullglob; for item in ./**; do if [[ "${item: -11}" = "protein.faa" ]]; then echo "${item}"; cp "${item}" ../ncbi-annotated-proteins/; fi; done`. I verified that there were 24 annotations matching what's available on NCBI (as of Nov 23rd 2026).

# Determining annotation quality notes (it's a lot, but tl;dr I will use BUSCO and PSAURON) #
	- This genome annotation tutorial provided useful background information and suggested the quality assessment tools compleasm and PSAURON.
	- The package compleasm was released in 2023 and reimplements BUSCO with Miniprot, supposedly making it faster and reducing underestimation of completeness (https://doi.org/10.1093/bioinformatics/btad595, https://github.com/huangnengCSU/compleasm/tree/main).
	- One more package, PSAURON, was released in 2025 and uses a machine learning model, trained on a reference set of coding sequences from 1090 eukaryotic NCBI RefSeq genomes, to evaluate whether regions in an annotation designated as coding sequences are likely to be actual protein-coding sequences (https://doi.org/10.1093/nargab/lqae189, https://github.com/salzberg-lab/PSAURON). This package reports a percentage of all annotated protein sequences "positively assessed" by PSAURON, and the authors describe it as a score of annotation accuracy confidence.
	- Some notes on BUSCO: BUSCO v6 released in 2025, and now has Miniprot as its default method (https://doi.org/10.1093/nar/gkae987). The user guide states that Miniprot has sensitivity issues with the detection of divergent orthologs, resulting in potential underperformance in species highly divergent from the ones used to produce the BUSCO dataset (https://busco.ezlab.org/busco_userguide.html). It also cautions that BUSCO's predicted transcripts when using Miniprot may have internal stop codons and should not be used for further analysis. The Metaeuk pipeline is an alternative to Miniprot that I could use with the --metaeuk option
	- The BUSCO vs compleasm question is talked about briefly in this 2024 lab blog post, but there weren't really any answers (https://www.treethinkers.info/en/post/busco-or-compleasm). 
	- The Goenomics Mendle blog, written by Martin Kollmar in 2025, brings up some BUSCO completeness myths and insights: 
		- We can't compare BUSCO completeness when using different lineages, because although single-copy genes in more general taxa can be expected to be single-copy genes in more specific taxa, the more specific taxa DO NOT contain all of the genes of the more general taxa -- "genes in more general taxa are not fully part of the gene set of the next specific taxa" (https://mendle.org/blog/busco-completeness-myths-debunked). 
		- BUSCO completeness evaluation of assemblies is different from evaluation of annotations -- the way genes and proteins are classified as "Fully complete single copy" versus "Fragmented" is supposedly more problematic in annotations (there's also another layer of potential errors here) -- proteins are more prone to being miscategorized as complete or missing -- so we can't compare assemblies and annotations, nor can we compare annotations with other annotations using BUSCO completeness alone? (https://mendle.org/blog/busco-completeness-myths-debunked-part-2)
		- Artificially fused genes in the assembly can alter missing/duplicated/complete results of their individual components depending on how many copies of the components vs fused copies are present -- supposedly, this inflates completeness (https://mendle.org/blog/busco-completeness-myths-debunked-part-3).
		- Repeated regions can be found in BUSCO data due to gene prediction artifacts. The author concludes that "when trying to reach BUSCO genome assembly statistics with your own genome annotation, you are likely to incorporate erroneous or mispredicted gene regions into your analysis", but I don't really understand what "reach BUSCO genome assembly statistics" means (https://mendle.org/blog/busco-completeness-myths-debunked-part-4).
		- Genome annotations will have more observations of duplicates than genome assemblies due to differences in hmmsearch, rather than for any biological reason (https://mendle.org/blog/busco-completeness-myths-debunked-part-5). Additionally, annotation vs assembly modes use different references to define full-length genes, so there will be inherent differences in the frequency of fragmented BUSCO genes also not due to any biological reason (https://mendle.org/blog/busco-completeness-myths-debunked-part-6). These technical biases make it so that we can't compare the number of complete vs duplicated vs fragmented BUSCO genes between assembly and annotation modes.
		- This blog also has some posts on functional annotation pitfalls that will be useful later (https://mendle.org/blog/functional-genome-annotation-dos-and-donts-part-2).


## My own sequencing ##
### Setup ###
I had my samples sequenced at the UW Biotechnology Center (UWBC), with Illumina NovaSeq for whole genome sequencing. We used a 10B flow cell, targeting 500 million reads (~50x coverage) per sample. I created a folder in data/ called illumina-sequencing and another called nanopore-sequencing in preparation for the future. In data/illumina-sequencing/, I created raw-reads/ and trimmed-reads/ for raw and trimmed reads. The UWBC deposited the reads into my advisor's ResearchDrive, so I copied the files over to my "work server" with the `scp -r {directory} {destination}` command.

 
