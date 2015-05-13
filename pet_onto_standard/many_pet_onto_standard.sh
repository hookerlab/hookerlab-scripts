#!/usr/bin/env bash
# Transforms many PET images into MNI space and normalizes to whole brain uptake
#
# Finds all the .nii PET images in a given directory, crawling down if needed, and
# runs `pet_onto_standard -f` on each image.
#
# See also `pet_onto_standard.sh`
#
# Example:
#       ./many_pet_on_standard.sh /autofs/cluster/PBR/PET/
#
usage()
{
    # Prints a help text
    SCRIPT_NAME=$1

    echo "Transforms many PET images into MNI space and normalizes to whole brain uptake."
    echo
    echo "usage: $SCRIPT_NAME [-h] pet_recon fs_recon_dir [dest_dir]"
    echo "       pet_recon_dir              the directory with the PET images"
    echo "       -h                         prints this text"
    echo
    echo " Example:"
    echo "  ./many_pet_on_standard.sh /autofs/cluster/PBR/PET"
}
get_destination_dir()
{
   (
   cd $PET_RECON_DIR
   echo $PET_ONTO_STANDARD_DIR/$(dirname $1)
   )
}
# Process the options passed to the script
SCRIPT_NAME=$0

while getopts ':hn' opt; do
    case "${opt}" in
        h) usage $SCRIPT_NAME; exit 0 ;;
        \?) echo "Invalid option"; usage $SCRIPT_NAME; exit 1 ;;
    esac
done

shift $(($OPTIND - 1))

# Process the arguments passed to the script
if ! ([ $# -eq 1  ]); then
    echo "Illegal number of parameters: must be 1"
    echo
    usage $SCRIPT_NAME
    exit 1
fi

# Check for the PET recon files
if !([ -d "$1" ]); then
    echo "Cannot find the directory $1"
    echo
    usage $SCRIPT_NAME
    exit 1

PET_RECON_DIR=$1
PET_ONTO_STANDARD_DIR=$(dirname $1)/$1-onto-standard
NIFTY_FILES=$(find $PET_RECON_DIR -name *.nii)

for file in "$NIFTY_FILES"
do
    FS_RECON_MAPFILE=$(dirname $file)/.${file%.nii}_fs_recon_map
    DESTINATION_DIR=$(get_destination_dir $file)
    if [ -f "$FS_RECON_MAPFILE" ]; then
        $FS_RECON_FILE=$(cat $FS_RECON_MAPFILE)
        bash ./pet_onto_standard.sh -f $file $FS_RECON_FILE $DESTINATION_DIR
    else
        echo "WARNING: Skipping $file as cannot find $FS_RECON_MAPFILE"
    fi
done
