#!/bin/bash

# This script will download the genome and annotation (if available) of the specified genome assemblies on NCBI.
# We need to input the quality of assemblies desired (high/med/low) -- refer to ../script-inputs/all-ncbi-genomes-20261105.csv and ../info/ncbi-ixodid-genomes-v1-20261105.pdf for more details. We'll take this as a single argument.

# This script depends on the NCBI datasets command line interface (ncbi-datasets-cli on Conda), version 18.41.1. It can be installed with `conda install conda-forge::ncbi-datasets-cli`. Make sure you are in the right Conda environment.

# Check if our input is invalid -- if so, we give an error message and stop the script.
if [[ "${1}" != "high" && "${1}" != "med" && "${1}" != "low" ]]; then
	echo "You did not give a proper input -- please pick one of 'high', 'med', or 'low'."
	exit
else
	# A nice little message to show that the input was valid
	echo "Downloading ${1}-quality assemblies!" 
fi

# Identify the NCBI assemblies .csv file (I will need to manually keep this up to date if the .csv changes)
ncbi_assemblies_csv="../script-inputs/all-ncbi-genomes-20261105.csv"

# Identify the destination directory, creating it if it does not already exist
downloads_destination="../ncbi-genomes/${1}-quality/"

# Start reading the .csv file of genome assemblies -- the while loop iterates through one line at a time
# It has four columns: accession number (acc_no), assembly name (name), annotation info (ann_info), and assembly quality (qual)
while IFS=$',' read -r acc_no name ann_info qual; do
	# Only work with genomes of the specified quality
	if [[ "${qual}" = "${1}" ]]; then
		# Check whether an annotation on NCBI is available 
		if [[ "${ann_info}" = "ncbi-ann" ]]; then
			# Run the NCBI datasets download command, downloading genome and annotation files
			# datasets download genome accession "${acc_no}" --filename "${name}" --include genome,gff3,cds,protein
			echo "Has annotation: ${acc_no}"
		else
			# Run the NCBI datasets download command, downloading only genome files
			# datasets download genome accession "${acc_no}" --filename "${name}" --include genome
			echo "No annotation: ${acc_no}"
		fi
	fi
done < "${ncbi_assemblies_csv}"

echo "All done! Genomes and available annotations downloaded to ${downloads_destination}!"
