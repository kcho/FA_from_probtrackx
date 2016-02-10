for subject in $@
do
    echo ${subject}
    echo ================
    for side in lh rh
    do
        echo ${side}
        tractDir=${subject}/tractography/${side}
        t1Img=${subject}/FREESURFER/mri/brain.nii.gz
        faImg=${subject}/DTI/DTI_FA.nii.gz
        waytotal=`cat ${tractDir}/waytotal`
        regMat=${subject}/registration/FREESURFERT1toNodif.mat
        wmMask=${subject}/ROI/${side}_wm_mask.nii.gz
        fcMask=${subject}/ROI/${side}_FC.nii.gz
        tcMask=${subject}/ROI/${side}_TC.nii.gz


        fslmaths ${tractDir}/fdt_paths.nii.gz -div ${waytotal} -thrp 2 -bin -mul ${wmMask} ${tractDir}/fdt_threshold.nii.gz

        ## take FC TC out : equivalent to -mul ${wmMask}

        # registration
        flirt \
            -in ${tractDir}/fdt_threshold.nii.gz \
            -ref ${faImg} \
            -applyxfm \
            -init ${regMat} \
            -out ${tractDir}/fdt_threshold_reg.nii.gz \
            -interp nearestneighbour

        # FA
        fslstats ${faImg} -k ${tractDir}/fdt_threshold_reg.nii.gz -M

        # fslview
        echo fslview ${wmMask} -l "Yellow" ${fcMask} -l "Red" ${tcMask} -l "Red" ${tractDir}/fdt_threshold.nii.gz -l "Green"
        echo fslview ${faImg} ${tractDir}/fdt_threshold_reg.nii.gz -l "Green"

    done
done
