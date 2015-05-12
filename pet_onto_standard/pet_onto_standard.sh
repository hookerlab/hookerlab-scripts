#!/usr/bin/env tcsh
## DATA ACQUIRED ON BAY 7, no L/R flip required!!!
## Using fslreorient2std
## in Aether, obtain final 60-90min recon nifti (e.g. with two-step single frame TAC recon)

setenv SUBJECT_ID HAYW_PBR
setenv SUBJECT_RECON HAYW_PBR_SUV60-90
setenv SUBJECTS_DIR /autofs/cluster/hookerlab/Users/Cristina/Huntington_FGD/FS/subjects/
setenv SUBJECT_DIR ${SUBJECTS_DIR}/${SUBJECT_ID}
setenv DESTINATION_DIR /autofs/cluster/hookerlab/Studies/PBR/Rosas/PET_onto_standard/${SUBJECT_ID}/PET-2-standard_2
setenv ORIGIN_DIR /autofs/cluster/hookerlab/Studies/PBR/Rosas/PET/${SUBJECT_ID}

# Make dir for this subject, copy the nifti file there, and move to that directory
mkdir -p ${DESTINATION_DIR}
cp ${ORIGIN_DIR}/${SUBJECT_RECON}.nii ${DESTINATION_DIR}/${SUBJECT_RECON}.nii
cd ${DESTINATION_DIR}

# Compute transformation matrix for linear registration of SUV with fs T1, with spm
spmregister --mov ${SUBJECT_RECON}.nii --s ${SUBJECT_ID} --reg SUV.lin_T1.dat --fsvol orig

# to CHECK REGISTRATION 
tkregister2 --mov ${SUBJECT_RECON}.nii --targ ${SUBJECT_DIR}/mri/orig.mgz --reg SUV.lin_T1.dat --surf orig

# Use tkergister to transform the matrix into .mat, and then invert the transformation matrix
tkregister2 --mov ${SUBJECT_RECON}.nii --targ ${SUBJECT_DIR}/mri/brainmask.mgz --reg SUV.lin_T1.dat --fslregout SUV.lin_T1.mat --noedit
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

flirt -noresample -in ${SUBJECT_RECON}.nii -ref T1-2mm_skullstripped.nii -applyxfm -init SUV.lin_T1.mat -out ${SUBJECT_RECON}.lin_T1.nii.gz

fslreorient2std ${SUBJECT_RECON}.lin_T1 ${SUBJECT_RECON}.lin_T1_orientOK
fslmaths ${SUBJECT_RECON}.lin_T1_orientOK -mas aparc+aseg_BIN-2mm_orientOK ${SUBJECT_RECON}.lin_T1_orientOK_skullstripped

# Find the input file for flirt
setenv FLIRT_DATADIR /autofs/space/lyon_006/pubsw/Linux2-2.3-x86_64/packages/fsl.64bit/4.1.4/
setenv MNI152_T1_2MM_BRAIN_NII $FLIRT_DATADIR/data/standard/MNI152_T1_2mm_brain.nii.gz

# flirt freesurfer mprage (T1-2mm_skullstripped) to MNI, to obtain the T1_lin_MNI152.mat matrix
flirt -ref T1-2mm_skullstripped_orientOK -in $MNI152_T1_2MM_BRAIN_NII -omat MNI152_lin_T1.mat 
convert_xfm -omat T1_lin_MNI152.mat -inverse MNI152_lin_T1.mat

# Apply non-linear registration of T1 to MNI
fnirt --ref=$MNI152_T1_2MM_BRAIN_NII --in=T1-2mm_orientOK.nii --aff=T1_lin_MNI152.mat --cout=T1_nl_MNI152.reg --config=T1_2_MNI152_2mm.cnf --iout=T1_nl_MNI152.nii

# Apply fnirt matrix to SUV
applywarp --ref=$MNI152_T1_2MM_BRAIN_NII --in=${SUBJECT_RECON}.lin_T1_orientOK_skullstripped --warp=T1_nl_MNI152.reg --out=${SUBJECT_RECON}.nl_MNI152

########################### Spatial smoothing #############################
# sigma=FWHM/2.355 ==> for 6mm is 2.55; See http://mathworld.wolfram.com/GaussianFunction.html

## 6mm smoothing of PET in MNI
fslmaths ${SUBJECT_RECON}.nl_MNI152 -kernel gauss 2.55 -fmean ${SUBJECT_RECON}.nl_MNI152_sm6mm -odt float

## 3mm smoothing, for visualization of subject-level PET in subject space with FSL
fslmaths ${SUBJECT_RECON}.lin_T1_orientOK_skullstripped -kernel gauss 1.27 -fmean ${SUBJECT_RECON}.lin_T1_orientOK_skullstripped_sm3mm -odt float

## 6mm smoothing, for visualization of subject-level PET in subject space with FSL
fslmaths ${SUBJECT_RECON}.lin_T1_orientOK_skullstripped -kernel gauss 2.55 -fmean ${SUBJECT_RECON}.lin_T1_orientOK_skullstripped_sm6mm -odt float

########################### Normalization #############################
# Normalization and smoothing of PET in MNI
fslmaths ${SUBJECT_RECON}.nl_MNI152 -mas ${FSL_DIR}/data/standard/MNI152_T1_2mm_brain_mask.nii.gz -inm 1 ${SUBJECT_RECON}.nl_MNI152_norm -odt float

fslmaths ${SUBJECT_RECON}.nl_MNI152_norm -kernel gauss 2.55 -fmean ${SUBJECT_RECON}.nl_MNI152_norm_sm6mm -odt float

# Normalization and smoothing of lin_T1_orientOK_skullstripped
fslmaths ${SUBJECT_RECON}.lin_T1_orientOK_skullstripped -mas aparc+aseg_BIN-2mm_orientOK -inm 1 ${SUBJECT_RECON}.lin_T1_orientOK_skullstripped_norm -odt float
fslmaths ${SUBJECT_RECON}.lin_T1_orientOK_skullstripped_norm -kernel gauss 2.55 -fmean ${SUBJECT_RECON}.lin_T1_orientOK_skullstripped_norm_sm6mm -odt float
