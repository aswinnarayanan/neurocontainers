#!/usr/bin/env bash
set -e

# this template file builds eeglab and is then used as a docker base image for layer caching
export toolName='eeglab'
export toolVersion='2020.0'
# Don't forget to update version change in README.md!!!!!

if [ "$1" != "" ]; then
    echo "Entering Debug mode"
    export debug="true"
fi

source ../main_setup.sh

neurodocker generate ${neurodocker_buildMode} \
   --base-image ubuntu:18.04 \
   --pkg-manager apt \
   --run="printf '#!/bin/bash\nls -la' > /usr/bin/ll" \
   --run="chmod +x /usr/bin/ll" \
   --run="mkdir ${mountPointList}" \
   --install openjdk-8-jre curl ca-certificates unzip \
   --matlabmcr version=2020a install_path=/opt/MCR  \
   --workdir /opt/${toolName}-${toolVersion}/ \
   --copy eeglab2020.0_mcr2020a.tar.gz /opt/${toolName}-${toolVersion}.tar.gz \
   --run="tar -xzf /opt/${toolName}-${toolVersion}.tar.gz -C /opt/${toolName}-${toolVersion}/ --strip-components 1" \
   --env LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:/opt/MCR/v98/runtime/glnxa64:/opt/MCR/v98/bin/glnxa64:/opt/MCR/v98/sys/os/glnxa64:/opt/MCR/v98/sys/opengl/lib/glnxa64 \
   --env XAPPLRESDIR=/opt/MCR/v98/x11/app-defaults \
   --env PATH=/opt/${toolName}-${toolVersion}/:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
   --env DEPLOY_BINS=${toolName} \
   --copy README.md /README.md \
  > ${imageName}.${neurodocker_buildExt}

if [ "$debug" = "true" ]; then
   ./../main_build.sh
fi

#Once you have final compiled archive in object storage:
#--run="curl -fsSL --retry 5 https://objectstorage.us-ashburn-1.oraclecloud.com/<INSERT_ADDRESS>/eeglab2020.0_mcr2020a.tar.gz \
#      | tar -xz -C /opt/${toolName}-${toolVersion}/ --strip-components 1" \
