#!/usr/bin/env bash
# Transforms a PET image into MNI space and normalizes to whole brain uptake
#
# This can be used with data acquired on Bay 6 and Bay 7.
#
# IMPORTANT: Scans from Bay 7 need to be reversed (left to right flip).
#          You can do this within the script just by passing the option -r.
#
# Example:
#       bash pet_on_standard.sh scan_from_bay_6.nii /autofs/cluster/PBR/FS/subjects/SCAC64H_PBR28
#
#       bash pet_on_standard.sh -r scan_from_bay_7.nii /autofs/cluster/PBR/FS/subjects/SCAC64H_PBR28
#
usage()
{
    # Prints a help text
    SCRIPT_NAME=$1

    echo "Transforms a PET image into MNI space and normalizes to whole brain uptake."
    echo
    echo "usage: $SCRIPT_NAME [-h] pet_recon fs_recon_dir [dest_dir]"
    echo "       pet_recon                  the reconstructed PET nifty file"
    echo "       fs_recon_dir               the directory with the Freesurfer reconstruction"
    echo "       dest_dir                   a directory to store the transformed image"
    echo "       -f                         do not check the registration"
    echo "       -r                         flip left->right (iff scanned on bay 7)
    echo "       -h                         prints this text"
    echo
    echo "By default, dest_dir is a pet-to-standard directory inside the directory where the" 
    echo "original image is."
    echo
    echo "IMPORTANT: Scans from Bay 7 need to be reversed (left to right flip)."
    echo "           You can do this within the script just by passing the option -r."
    echo
    echo " Example:"
    echo "  ./pet_on_standard.sh ./SCAC_PBR_SUV_60-90.nii /cluster/PBR/FS/subjects/SCAC64H_PBR28"
}
get_abspath()
{
   (
   cd $(dirname $1)
   echo $PWD/$(basename $1)
   )
}

# Process the options passed to the script
SCRIPT_NAME=$0
CHECK_REGISTRATION=1
SHOULD_FLIP=0 ;;

while getopts ':hn' opt; do
    case "${opt}" in
        h) usage $SCRIPT_NAME; exit 0 ;;
        f) CHECK_REGISTRATION=0 ;;
        r) SHOULD_FLIP=1 ;;
        \?) echo "Invalid option"; usage $SCRIPT_NAME; exit 1 ;;
    esac
done

shift $(($OPTIND - 1))

# Process the arguments passed to the script
if [[ $# < 2 || $# > 3 ]]; then
    echo "Illegal number of parameters: must be 2 or 3"
    echo
    usage $SCRIPT_NAME
    exit 1
fi

# Check for the PET recon files
if !([ -f "$1" ]); then
    echo "Cannot find image file $1"
    echo
    usage $SCRIPT_NAME
    exit 1
fi
PET_RECON_DIR=$(dirname $1)
PET_RECON=$(basename $1)
PET_RECON=$(echo ${PET_RECON%.nii})

# Check for the Freesurfer recon directory
if !([ -d "$2" ]); then
    echo "Cannot find the Freesurfer reconstruction directory $2"
    echo
    usage $SCRIPT_NAME
    exit 1
fi
FREESURFER_RECON=$2
FREESURFER_ID=$(basename ${FREESURFER_RECON})

#Save the location of the Freesurfer reconstruction
FS_RECON_MAPFILE=$PET_RECON_DIR/.${PET_RECON%.nii}_fs_recon_map
echo $(get_abspath $2) > $FS_RECON_MAPFILE

# Check the output directory exists or create it
if [ $# < 3 ] ; then
    DESTINATION_DIR=${PET_RECON_DIR}/pet-to-standard
else
    DESTINATION_DIR=$3
fi

# Make dir for this subject, copy or flip the nifti file there, and move to that directory
mkdir -p ${DESTINATION_DIR}
if [ $SHOULD_FLIP -eq 1 ]; then
    mri_convert --left-right-reverse-pix ${PET_RECON_DIR}/${PET_RECON}.nii ${DESTINATION_DIR}/${PET_RECON}.nii
else
    cp ${PET_RECON_DIR}/${PET_RECON}.nii ${DESTINATION_DIR}/${PET_RECON}.nii
fi
cd ${DESTINATION_DIR}

# Compute transformation matrix for linear registration of SUV with fs T1, with spm
spmregister --mov ${PET_RECON}.nii --s ${FREESURFER_RECON} --reg SUV.lin_T1.dat --fsvol orig

# to check registration
if [ $CHECK_REGISTRATION -eq 1 ]; then
    tkregister2 --mov ${PET_RECON}.nii --targ ${SUBJECT_DIR}/mri/orig.mgz --reg SUV.lin_T1.dat --surf orig
fi

# Use tkergister to transform the matrix into .mat, and then invert the transformation matrix
tkregister2 --mov ${PET_RECON}.nii --targ ${SUBJECT_DIR}/mri/brainmask.mgz --reg SUV.lin_T1.dat --fslregout SUV.lin_T1.mat --noedit
convert_xfm -omat T1_lin_SUV.mat -inverse SUV.lin_T1.mat

######################## Apply T1 to SUV registration ##########################

# Convert various files and reorient to standard to match MNI/fsl coordinates system
mri_convert ${SUBJECT_DIR}/mri/brainmask.mgz brainmask.nii
mri_convert ${SUBJECT_DIR}/mri/T1.mgz T1.nii
mri_binarize --i ${SUBJECT_DIR}/mri/aparc+aseg.mgz --min 0.5 --dilate 2 --o aparc+aseg_BIN.nii 
3dresample -dxyz 2 2 2 -master brainmask.nii  -inset brainmask.nii -prefix brainmask-2mm.nii
3dresample -dxyz 2 2 2 -master T1.nii  -inset T1.nii -prefix T1-2mm.nii
3dresample -dxyz 2 2 2 -master aparc+aseg_BIN.nii  -inset aparc+aseg_BIN.nii -prefix aparc+aseg_BIN-2mm.nii

fslreorient2std brainmask.nii brainmask_orientOK.nii
fslreorient2std aparc+aseg_BIN-2mm aparc+aseg_BIN-2mm_orientOK.nii
fslreorient2std brainmask-2mm.nii brainmask-2mm_orientOK.nii
fslreorient2std T1-2mm.nii T1-2mm_orientOK.nii
fslmaths T1-2mm.nii -mas aparc+aseg_BIN-2mm.nii T1-2mm_skullstripped.nii
fslmaths T1-2mm_orientOK.nii -mas aparc+aseg_BIN-2mm_orientOK.nii T1-2mm_skullstripped_orientOK.nii

flirt -noresample -in ${PET_RECON}.nii -ref T1-2mm_skullstripped.nii -applyxfm -init SUV.lin_T1.mat -out ${PET_RECON}.lin_T1.nii.gz

fslreorient2std ${PET_RECON}.lin_T1 ${PET_RECON}.lin_T1_orientOK
fslmaths ${PET_RECON}.lin_T1_orientOK -mas aparc+aseg_BIN-2mm_orientOK ${PET_RECON}.lin_T1_orientOK_skullstripped

# Find the input file for flirt
setenv FLIRT_DATADIR /autofs/space/lyon_006/pubsw/Linux2-2.3-x86_64/packages/fsl.64bit/4.1.4/
setenv MNI152_T1_2MM_BRAIN_NII ${FLIRT_DATADIR}/data/standard/MNI152_T1_2mm_brain.nii.gz

# flirt freesurfer mprage (T1-2mm_skullstripped) to MNI, to obtain the T1_lin_MNI152.mat matrix
flirt -ref T1-2mm_skullstripped_orientOK -in ${MNI152_T1_2MM_BRAIN_NII} -omat MNI152_lin_T1.mat 
convert_xfm -omat T1_lin_MNI152.mat -inverse MNI152_lin_T1.mat

# Apply non-linear registration of T1 to MNI
fnirt --ref=${MNI152_T1_2MM_BRAIN_NII} --in=T1-2mm_orientOK.nii --aff=T1_lin_MNI152.mat --cout=T1_nl_MNI152.reg --config=T1_2_MNI152_2mm.cnf --iout=T1_nl_MNI152.nii

# Apply fnirt matrix to SUV
applywarp --ref=${MNI152_T1_2MM_BRAIN_NII} --in=${PET_RECON}.lin_T1_orientOK_skullstripped --warp=T1_nl_MNI152.reg --out=${PET_RECON}.nl_MNI152

########################### Spatial smoothing #############################
# sigma=FWHM/2.355 ==> for 6mm is 2.55; See http://mathworld.wolfram.com/GaussianFunction.html

## 6mm smoothing of PET in MNI
fslmaths ${PET_RECON}.nl_MNI152 -kernel gauss 2.55 -fmean ${PET_RECON}.nl_MNI152_sm6mm -odt float

## 3mm smoothing, for visualization of subject-level PET in subject space with FSL
fslmaths ${PET_RECON}.lin_T1_orientOK_skullstripped -kernel gauss 1.27 -fmean ${PET_RECON}.lin_T1_orientOK_skullstripped_sm3mm -odt float

## 6mm smoothing, for visualization of subject-level PET in subject space with FSL
fslmaths ${PET_RECON}.lin_T1_orientOK_skullstripped -kernel gauss 2.55 -fmean ${PET_RECON}.lin_T1_orientOK_skullstripped_sm6mm -odt float

########################### Normalization #############################
# Normalization and smoothing of PET in MNI
fslmaths ${PET_RECON}.nl_MNI152 -mas ${FSL_DIR}/data/standard/MNI152_T1_2mm_brain_mask.nii.gz -inm 1 ${PET_RECON}.nl_MNI152_norm -odt float

fslmaths ${PET_RECON}.nl_MNI152_norm -kernel gauss 2.55 -fmean ${PET_RECON}.nl_MNI152_norm_sm6mm -odt float

# Normalization and smoothing of lin_T1_orientOK_skullstripped
fslmaths ${PET_RECON}.lin_T1_orientOK_skullstripped -mas aparc+aseg_BIN-2mm_orientOK -inm 1 ${PET_RECON}.lin_T1_orientOK_skullstripped_norm -odt float
fslmaths ${PET_RECON}.lin_T1_orientOK_skullstripped_norm -kernel gauss 2.55 -fmean ${PET_RECON}.lin_T1_orientOK_skullstripped_norm_sm6mm -odt float

# All done!
echo "Transformed PET image stored in ${DESTINATION_DIR}/${PET_RECON}.nii"
