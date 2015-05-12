#!/usr/bin/env bash
# Finds and unpacks the data files for a given subject.
#
# This script should run on one of the clusters at the Martinos, as assumes the
# filesystem is the same as there. This script does not copy the data to another machine, 
# you have to do this with another script.
# 
# It does part of the job of the "Organize files" steps in the Masamune software, but
# runs entirely on the remote machine. This avoids doing multiple ssh connections to check
# whether the unpacking process has ended.
#
# Example:
#     ./unpack_files.sh MSTAT_001_01
#
usage()
{
    # Prints a help text
    SCRIPT_NAME=$1

    echo "Finds and unpacks the data files for a given subject."
    echo
    echo "usage: $SCRIPT_NAME [-h] subject_id"
    echo "       subject_id                 the subject ID"
    echo "       -h                         prints this text"
    echo
    echo " Example:"
    echo "     ./unpack_files.sh MSTAT_001_01"
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
if !([ $# -eq 1 ]) ; then
    echo "Illegal number of parameters: must be 1."
    echo
    usage $SCRIPT_NAME
    exit 1
fi

SUBJECT_ID=$1

# Load_the Freesurfer env
FREESURFER="/usr/local/freesurfer/nmr-stable53-env"
if !([ -e $FREESURFER ]); then
     echo "Freesurfer not found at $FREESURFER."
     exit 1
fi

# Check whether the log folder exists
LOG_DIR="/autofs/cluster/pubsw/2/pubsw/Linux2-2.3-x86_64/packages/mrpet"
if !([ -d "$LOG_DIR" ]); then
     echo "Cannot store log files: directory $LOG_DIR not found."
     exit 1
fi

# Get the path to the subject data
#
# Uses the findsession command from Freesurfer, which outputs several lines
# with one containing the path to the data in this format:
#
# PATH   :  /cluster/archive/308/siemens/TrioTim-35101-20141002-102120-000825
# 
# If the subject id is not found, the output of findsession is empty.
#
PATH_TO_DATA="$(findsession $SUBJECT_ID | grep PATH | cut -d ':' -f 2 | sed -e 's/^[[:space:]]*//')"
if [ -z "$PATH_TO_DATA" ]; then
    echo "Subject $SUBJECT_ID not found."
    exit 1
else
    echo "Data for subject $SUBJECT_ID found at $PATH_TO_DATA."
fi

# Check that you have permissions to access to the data, i.e. either is yours
# or you belong to the group who owns it.
#
USERNAME="$(whoami)"
GROUP_OWING_DATA="$(stat -c %G $PATH_TO_DATA)"
HAVE_PERMISSIONS="$(getent group $GROUP_OWING_DATA | cut -d ':' -f 4 | grep -w $USERNAME)"
if [ -z "$HAVE_PERMISSIONS" ] && !( [ "$GROUP_OWING_DATA" = "$USERNAME" ] ); then
    echo "You don't have permissions to access the data: you need to belong to the $GROUP_OWING_DATA group."
    exit 1
fi

# Create a scratch folder
TODAY="$(date +%A | tr A-Z a-z)"
BOURGET="/autofs/cluster/scratch/$TODAY/$USERNAME/$SUBJECT_ID/BourgetOldMRnames"
mkdir -p $BOURGET

# Unpack, clean, and archive the log file
dcm2oldname $PATH_TO_DATA $BOURGET
tcsh -c "source $FREESURFER; unpacksdcmdir -src $BOURGET -targ $BOURGET -scanonly '$BOURGET/$SUBJECT_ID.log'"

rm -f "$BOURGET/unpack.log" "$BOURGET/dicomdir.sumfile"
echo "Unpacking complete, you can pick up your log file in $BOURGET"
cp -f "$BOURGET/$SUBJECT_ID.log" "$LOG_DIR/$SUBJECT_ID.log"
COPIED=$?
if [ $COPIED -eq 0 ]; then
     echo "A copy has been archived into $LOG_DIR."
else
     echo "WARNING: Copying into $LOG_DIR has failed because you don't have permissions to write there."
fi
