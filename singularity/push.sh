#!/bin/bash

# IMAGENAME=template_1.0
# BUILDDATE=20231214
# DOCKER_REGISTRY=neurodesk

_base=./


# containerName=afni
# containerVersion=21.2.00
# containerDate=20210714

user=neurodesk
# user=aswinnarayanan
containerName=itksnap
containerVersion=4.0.2

# containerDate=20240202
# containerName=fsl
# containerVersion=6.0.7.8
# containerDate=20240913


# echo "{TOKEN}" | gh auth login --with-token

container=itksnap
versions=$(gh api /users/$user/packages/container/${containerName}_${containerVersion}/versions | jq "[{ tags: .[].metadata.container.tags,}]")

echo $versions

re='^[0-9]+$'
for containerDate in $(echo $versions | jq -rc '.[].tags | .[]'); do
    if [[ $containerDate =~ $re ]]; then
        echo $containerDate`
        docker pull ghcr.io/neurodesk/${containerName}_${containerVersion}:${containerDate}
        docker image tag ghcr.io/neurodesk/${containerName}_${containerVersion}:${containerDate} ghcr.io/aswinnarayanan/${containerName}:${containerVersion}-${containerDate}
        docker push ghcr.io/aswinnarayanan/${containerName}:${containerVersion}-${containerDate}
        apptainer pull --force docker://ghcr.io/aswinnarayanan/${containerName}:${containerVersion}-${containerDate}
        apptainer push ./${containerName}_${containerVersion}-${containerDate}.sif oras://ghcr.io/aswinnarayanan/${containerName}:${containerVersion}-${containerDate}-sif
    fi
done    
