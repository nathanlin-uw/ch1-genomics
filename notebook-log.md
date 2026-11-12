This is the notebook log for chapter 1, the genomics portion, of my Master's thesis.

### Setting up this GitHub Repo ###
I first created this repository on the GitHub website, initializing it with a README and the MIT license. 

In the terminal, I used `git clone https://github.com/nathanlin-uw/ch1-genomics.git` to create a copy of the repository on my computer, then updated the README, created this log, and started a .gitignore.

To push changes back to the online repository, I use `git add .`, `git status`, `git commit -m "Commit message"`, and `git push`.

### Setting up folder system & NCBI genomes review ###
To start, I made a folder for scripts, a folder for script inputs, and a folder for genomes downloaded from NCBI, using `mkdir ncbi-genomes`, `mkdir scripts`, etc. I added a README to each folder.

I also added a folder, info/, for background information. Into this folder I placed ncbi-ixodid-genomes-v1-20261105.pdf, my review of genomes available on NCBI, where I gathered information on the assemblies, located their corresponding publications, and arranged them based on assembly quality. Using this information, I created all-ncbi-genomes-20261105.csv, which contains the accession number, the name I assigned, whether an annotation is available, and the genome quality -- this is found in script-inputs/.

### Setting up Conda ###
The Conda package and environment manager is used to download many of the packages we will need. 

I installed miniconda3 to my home/ntlin/ (aka ~/) directory, running through the installer and choosing to initialize Conda automatically (this is very important in order to make the conda command available after the installation!!), with `bash Miniconda3-latest-Linux-x86_64.sh`. After reopening the terminal or using the refresh command `source ~/.bashrc`, the `conda` command is now available! I used `conda config --auto_activate_base false` to make it so that I don't automatically go into the base environment on startup.

I used `conda info` to learn that my Conda is version 26.9.3, my Python is version 3.14.8.final.0, and the distribution I used was Miniconda3 py314_26.9.3-0 (sh, linux-64). The next day, I updated Conda to 26.9.4 with `conda self update`.

### Downloading genomes from NCBI ###
I created a script, 01-ncbi-downloading.sh, for downloading a set of NCBI genomes (and protein-coding genes, if an annotation is available), for a specified quality. I intend to 1) retrieve the genome sequences for each assembly, 2) retrieve a list of protein-coding genes for assemblies with high-quality annotations to concatenate for a "full genes list", and 3) retrieve whatever is necessary to run OrthoFinder on the same assemblies with high-quality annotations.

My notes for thinking through and writing this script are below:
- Determining annotation quality: 
- Orthofinder input: 
- Extracting information from csvs: 
- Iteration in Bash: 
- NCBI command line interface: 
