#!/bin/bash

# This script will download the genome and annotation (if available) of the specified genome assemblies on NCBI.
# We need to input the quality of assemblies desired (high/med/low) -- refer to ../script-inputs/all-ncbi-genomes-20261105.csv and ../info/ncbi-ixodid-genomes-v1-20261105.pdf for more details. We'll take this as a single argument.

# This script depends on the NCBI datasets command line interface (ncbi-datasets-cli on Conda), version 18.41.1. It can be installed with `conda install conda-forge::ncbi-datasets-cli`. Make sure you are in the right Conda environment.

# Make sure I'm in the scripts/ folder
cd "$(dirname '${0}')"

# Check if our input is invalid -- if so, we give an error message and stop the script.
if [[ "${1}" != "high" && "${1}" != "med" && "${1}" != "low" && "${1}" != "legacy-for-annotation" ]]; then
	echo "You did not give a proper input -- please pick one of 'high', 'med', 'low', or 'legacy-for-annotation'."
	exit 1
else
	# A nice little message to show that the input was valid
	echo "Downloading ${1}-quality assemblies!" 
fi

# Check if we have access to the ncbi-datasets-cli package -- if not, give an error and stop the script.
if ! command -v datasets >/dev/null 2>&1; then
	echo "Check your Conda environment! We need to be able to access the datasets command." >&2
	exit 1
fi 

# Identify the NCBI assemblies .csv file (I will need to manually keep this up to date if the .csv changes)
ncbi_assemblies_csv="../script-inputs/all-ncbi-genomes-20261123.csv"

# Identify the destination directory, creating it if it does not already exist
downloads_destination="../ncbi-genomes/${1}-quality"
# I'm going to have this start from scratch every time, so it will delete and recreate the directory each time
if [[ -e "${downloads_destination}" ]]; then
	rm -r "${downloads_destination}"
fi
mkdir "${downloads_destination}"

# Start reading the .csv file of genome assemblies -- the while loop iterates through one line at a time
# It has four columns: accession number (acc_no), assembly name (name), annotation info (ann_info), and assembly quality (qual)
while IFS=$',' read -r acc_no name ann_info qual; do
	# Only work with genomes of the specified quality
	if [[ "${qual}" = "${1}" ]]; then
		# Check whether an annotation on NCBI is available (this is a remnant when I thought asking for protein/cds files for assemblies without them would cause an error)
		if [[ "${ann_info}" = "ncbi-ann" || "${ann_info: 0: 8}" = "ncbi-ann" ]]; then
			# I'm just going to condense it to one line
			echo "Has annotation: ${acc_no}"; else echo "No annotation: ${acc_no}"; fi
		# Run the NCBI datasets download command, downloading genome and any available annotation files
		datasets download genome accession "${acc_no}" --filename "${downloads_destination}/${name}.zip" --include genome,gff3,cds,protein
		## NCBI CLI downloads a .zip file, so extract the relevant files and clean up the space
		## Upon unzipping, sequences are found in ./ncbi_dataset/data/{accession number}/  
		# Unzip the output into the download destination folder
		unzip "${downloads_destination}/${name}.zip" -d "${downloads_destination}"
		# Pull out the contents and rename it (remember that we are in scripts/)
		mv "${downloads_destination}/ncbi_dataset/data/${acc_no}" "${downloads_destination}/${name}/"
		# Remove the zip file, md5sum, README, and ncbi_dataset folder
		rm "${downloads_destination}/${name}.zip"
		rm "${downloads_destination}/README.md"
		rm "${downloads_destination}/md5sum.txt"
		rm -r "${downloads_destination}/ncbi_dataset/"
		# Rename each individual file in the folder, attaching the assembly name in front
		for file in "${downloads_destination}/${name}"/*; do
			# Attach the name in front (use parameter expansion to get only file name)
			mv "${file}" "${downloads_destination}/${name}/${name}_${file##*/}"
		done
	fi
done < "${ncbi_assemblies_csv}"

echo "All done! Genomes and available annotations downloaded to ${downloads_destination}!"
