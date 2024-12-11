#!/bin/bash

# https://medium.com/@chamilad/lets-make-your-docker-image-better-than-90-of-existing-ones-8b1e5de950d

email="mail.neurodesk@gmail.com"
GITHUB_SHA="0259f7d74df0ca80a9f735b2bae58b05606ff724"
SHORT_SHA=$(echo $GITHUB_SHA | cut -c1-7)
website="https://www.neurodesk.org"
gitUrl="https://github.com/NeuroDesk/neurocontainers.git"
user=aswinnarayanan
containerName=itksnap
containerVersion=4.0.2


BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ')
containerDate=$(date -u +'%Y%m%d')
containerDesc="itksnap is an image viewer for DICOM and NII files and supports manual segmentation of data."

cacheVersion=${containerVersion}-20240202

# docker build . --file ${IMAGENAME}.Dockerfile --tag $IMAGEID:$SHORT_SHA --cache-from $IMAGEID --label "GITHUB_REPOSITORY=$GITHUB_REPOSITORY" --label "GITHUB_SHA=$GITHUB_SHA"
# docker build . --build-arg BUILD_DATE=${BUILD_DATE} --tag ghcr.io/aswinnarayanan/${containerName}:${containerVersion}-${containerDate}


IMAGEID=ghcr.io/aswinnarayanan/${containerName}
echo "[DEBUG] Pulling $IMAGEID"
{
  docker pull $IMAGEID:${cacheVersion} \
    && ROOTFS_CACHE=$(docker inspect --format='{{.RootFS}}' $IMAGEID:${cacheVersion})
} || echo "$IMAGEID:${containerVersion}-${cacheVersion} not found. Resuming build..."

docker build . --build-arg BUILD_DATE=${BUILD_DATE} --tag $IMAGEID:$SHORT_SHA --cache-from $IMAGEID:${cacheVersion} \
    --label org.opencontainers.image.created=$BUILD_DATE \
    --label org.opencontainers.image.authors="${email}" \
    --label org.opencontainers.image.url="${website}" \
    --label org.opencontainers.image.documentation="${website}" \
    --label org.opencontainers.image.source="${gitUrl}" \
    --label org.opencontainers.image.version="${containerVersion}-${containerDate}" \
    --label org.opencontainers.image.revision="${GITHUB_SHA}" \
    --label org.opencontainers.image.vendor="${user}" \
    --label org.opencontainers.image.licenses="" \
    --label org.opencontainers.image.ref.name="${containerName}" \
    --label org.opencontainers.image.title="${containerName}" \
    --label org.opencontainers.image.description="${containerDesc}" \
    --label org.opencontainers.image.base.digest="sha256:3d1556a8a18cf5307b121e0a98e93f1ddf1f3f8e092f1fddfd941254785b95d7" \
    --label org.opencontainers.image.base.name="ubuntu:22.04" \

echo "[DEBUG] # Get image RootFS to check for changes ..."
ROOTFS_NEW=$(docker inspect --format='{{.RootFS}}' $IMAGEID:$SHORT_SHA)

# Tag and Push if new image RootFS differs from cached image
if [ "$ROOTFS_NEW" = "$ROOTFS_CACHE" ]; then
    echo "[DEBUG] Skipping push to registry. No changes found"
else
    echo "[DEBUG] Changes found"
    docker push $IMAGEID:${containerVersion}-${containerDate}
fi




