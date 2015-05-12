#!/usr/bin/env bash
# Retrieves MR data for a given subject from a remote machine into a local folder.
#
# Example:
#     ./retrieve_mr_data.sh my_study MSTAT_001-01
#
usage()
{
    # Prints a help text
    SCRIPT_NAME=$1

    echo "Retrieves MR data for a given subject from a remote machine into a local folder"
    echo
    echo "usage: $SCRIPT_NAME [-hn] output_dir subject_id"
    echo "       subject_id                 subject id as in the DICOM image"
    echo "       output_dir                 the directory where the subject folder is"
    echo "       -h                         prints this text"
    echo "       -n                         dry run, does nothing but prints out what would do"
    echo "       -s                         IP or hostname of the remote machine (defaults to Brain-Vision)"
    echo "       -u                         your username in the remote machine (defaults to the local username)"
    echo
    echo " Example:"
    echo "     ./retrieve_mr_data.sh -u iglpdc my_study MSTAT_001_01"
}
# Process the options passed to the script
SCRIPT_NAME=$0
BIN_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
REMOTE_USER=$(whoami)
REMOTE_MACHINE='172.20.180.53'
DRY_RUN=false

while getopts ':hns:u:' opt; do
    case "${opt}" in
        n) DRY_RUN=true ;;
        s) REMOTE_MACHINE=$OPTARG;;
        u) REMOTE_USER=$OPTARG ;;
        h) usage $SCRIPT_NAME; exit 0 ;;
        \?) echo "Invalid option"; usage $SCRIPT_NAME; exit 1 ;;
    esac
done

shift $(($OPTIND - 1))

# Process the arguments passed to the script
if !([ $# -eq 2 ]) ; then
    echo "Illegal number of parameters: must be 2."
    echo
    usage $SCRIPT_NAME
    exit 1
fi

# Check for the study and subject folder. We do this because currently the subject folder
								# must be created beforehand by the scanner technicians to copy the PET info
OUTPUT_DIR=$1
SUBJECT_ID=$2

SUBJECT_DIR=$OUTPUT_DIR/$SUBJECT_ID
if [ ! -d "$SUBJECT_DIR" ]; then
    echo "Directory '$SUBJECT_DIR' not found."
    exit 1
fi

# Unpack the subject MR data remotely
LOG_FILE=$SUBJECT_DIR/$SUBJECT_ID.log
ssh $REMOTE_USER@$REMOTE_MACHINE 'bash -s' < $BIN_DIR/unpack_files.sh $SUBJECT_ID | tee $LOG_FILE
REMOTE_FOLDER="$(cat $LOG_FILE | grep -w "Unpacking" | grep -oE "[^ ]+$")"
if [ -z "$REMOTE_FOLDER" ]; then
    echo "Unpacking went wrong. Remote folder for unpacking not found."
    exit 1
fi

# Copy the files from the remote machine to the subject folder
MR_DIR=$SUBJECT_DIR/MR
if !([ -e "$MR_DIR" ]); then
    echo "Directory $MR_DIR is missing. Creating it"
    mkdir $MR_DIR
elif !([ -d "$MR_DIR" ]); then
    echo "$MR_DIR is a file, not a directory. You should delete it. Exiting without copying the files."
    exit 1
fi
ssh $REMOTE_USER@$REMOTE_MACHINE "cd $REMOTE_FOLDER && tar -czf - . " | (cd $MR_DIR && tar -xpzf -)
if [ $? ]; then
    echo "MR files copied to $MR_DIR."
fi
exit 0
