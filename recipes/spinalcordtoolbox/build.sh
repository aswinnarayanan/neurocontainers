#!/usr/bin/env bash
set -e

export toolName='spinalcordtoolbox'
export toolVersion='master'

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug="true"
fi

source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base ubuntu:16.04 \
   --pkg-manager apt \
   --install="gcc libmpich-dev python3-pyqt5 git curl bzip2 libglib2.0-0" \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir ${mountPointList}" \
   --workdir="/opt/${toolName}-${toolVersion}" \
   --run="git clone https://github.com/neuropoly/spinalcordtoolbox /opt/${toolName}-${toolVersion}" \
   --workdir="/opt/${toolName}-${toolVersion}/" \
   --run="git checkout ${toolVersion}" \
   --run="chmod a+rwx /opt/${toolName}-${toolVersion}/" \
   --user=${toolName} \
  > ${toolName}_${toolVersion}.Dockerfile

   # --run="yes | ./install_sct -i" \
   # --env DEPLOY_PATH=/opt/${toolName}-${toolVersion}/bin/ \
   # --env PATH=/opt/${toolName}-${toolVersion}/bin/:$PATH \
   # --run="sct_deepseg -install-task seg_mice_gm-wm_dwi" \
   # --run="sct_deepseg -install-task seg_tumor-edema-cavity_t1-t2" \
   # --run="sct_deepseg -install-task seg_tumor_t2" \
   # --run="sct_deepseg -install-task seg_mice_gm" \
   # --run="sct_deepseg -install-task seg_mice_sc" \
   # --copy README.md /README.md \


if [ "$debug" = "true" ]; then
   ./../main_build.sh
fi
