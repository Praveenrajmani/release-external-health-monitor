#!/bin/bash
# This file is part of MinIO, Inc.
# Copyright (c) 2023 MinIO, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

ME=$(basename "$0"); export ME
cd "$(dirname "$0")" || exit 255

set -o errexit
set -o nounset
set -o pipefail

declare BUILD_VERSION PODMAN IMAGE_TAG_BASE IMG

function init() {
    if [ "$#" -ne 1 ]; then
        cat <<EOF
USAGE:
  ${ME} <VERSION>

EXAMPLE:
  $ ${ME} 0.10.0
EOF
        exit 255
    fi

    BUILD_VERSION="${1/v/}"
    IMAGE_TAG_BASE=quay.io/praveen8/csi-external-health-monitor-controller
    IMG="${IMAGE_TAG_BASE}:v${BUILD_VERSION}"

    if which podman >/dev/null 2>&1; then
        PODMAN=podman
    elif which docker >/dev/null 2>&1; then
        PODMAN=docker
    else
        echo "no podman or docker found; please install"
        exit 255
    fi   
}

function main() {
    # Downloading the source tar
    curl --silent --location --insecure --fail "https://github.com/kubernetes-csi/external-health-monitor/archive/refs/tags/v${BUILD_VERSION}.tar.gz" | tar -zxf -
    cd external-health-monitor-"${BUILD_VERSION}"
    make build
    cp ../Dockerfile cmd/csi-external-health-monitor-controller/
    cp LICENSE cmd/csi-external-health-monitor-controller/

    # Build the image
    "${PODMAN}" buildx build --platform linux/amd64 -f cmd/csi-external-health-monitor-controller/Dockerfile --tag "${IMG}" .
    "${PODMAN}" push "${IMG}"

    # cleanup
    cd - && rm -rf external-health-monitor-"${BUILD_VERSION}"    
}

init "$@"
main "$@"
