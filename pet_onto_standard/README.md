# Overview

To run the script on one PET image, just do:

~~~
$ bash pet_on_standard.sh PET/SCAC64H_PBR28/SCAC_PBR_SUV_60-90.nii /autofs/cluster/PBR/FS/subjects/SCAC64H_PBR28
~~~

where the first argument is the location of your PET image (as a `.nii` file), and the second is the directory with the corresponding Freesurfer reconstruction.

If you need to re-run the script on the same data, you can use the `-f` to avoid the registration check.

## Rerun for several subjects

If you need to re-run the script for all the subjects in a big study, you can use:

~~~
$ bash many_pet_onto_standard.sh PET/
~~~

where `PET` is the directory containing all the subjects.