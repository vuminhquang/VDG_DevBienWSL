#!/bin/sh

set -e

# Variables
BASEIMAGE=${BASEIMAGE:-debian:buster}
GOLANG_VERSION=${GOLANG_VERSION:-1.16.5}
PKG_NAME=${PKG_NAME:-nvidia-container-toolkit}
PKG_VERS=${PKG_VERS:-1.0.0}
PKG_REV=${PKG_REV:-1}
GIT_COMMIT=${GIT_COMMIT:-latest}
LIBNVIDIA_CONTAINER_TOOLS_VERSION=${LIBNVIDIA_CONTAINER_TOOLS_VERSION:-1.0.0}

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
  echo "Switching to root to run the script..."
  exec su -c "sh $0" root
fi

# Update and install dependencies
export DEBIAN_FRONTEND=noninteractive
apt-get update && apt-get install -y --no-install-recommends \
  wget \
  ca-certificates \
  git \
  build-essential \
  dh-make \
  fakeroot \
  devscripts \
  lsb-release \
  curl

# Clean up APT caches
rm -rf /var/lib/apt/lists/*

# Add backports repository
echo "deb http://ftp.debian.org/debian $(lsb_release -cs)-backports main" > /etc/apt/sources.list.d/backports.list

# Download and install Go
arch="$(uname -m)"
case "${arch##*-}" in
  x86_64 | amd64) ARCH='amd64' ;;
  ppc64el | ppc64le) ARCH='ppc64le' ;;
  aarch64 | arm64) ARCH='arm64' ;;
  *) echo "unsupported architecture" ; exit 1 ;;
esac
wget -nv -O - https://storage.googleapis.com/golang/go${GOLANG_VERSION}.linux-${ARCH}.tar.gz | tar -C /usr/local -xz

# Set up Go environment
export GOPATH=/go
export PATH=$GOPATH/bin:/usr/local/go/bin:$PATH

# Prepare packaging environment
export DEBFULLNAME="NVIDIA CORPORATION"
export DEBEMAIL="cudatools@nvidia.com"
export REVISION="$PKG_VERS-$PKG_REV"
export SECTION=""

# Output directory
DIST_DIR=/tmp/nvidia-container-toolkit-$PKG_VERS
mkdir -p $DIST_DIR /dist

# Clone the repository and build the toolkit
WORKDIR=$GOPATH/src/nvidia-container-toolkit
git clone https://gitlab.com/nvidia/container-toolkit/container-toolkit.git $WORKDIR
cd $WORKDIR

# Checkout the specific commit, if provided
if [ "$GIT_COMMIT" != "latest" ]; then
  git checkout $GIT_COMMIT
fi

# Build the toolkit
make PREFIX=${DIST_DIR} cmds

# Prepare Debian packaging
cd $DIST_DIR
cp -r $WORKDIR/packaging/debian .

# Update changelog
dch --create --package="${PKG_NAME}" \
  --newversion "${REVISION}" \
  "See https://gitlab.com/nvidia/container-toolkit/container-toolkit/-/blob/${GIT_COMMIT}/CHANGELOG.md for the changelog"
dch --append "Bump libnvidia-container dependency to ${LIBNVIDIA_CONTAINER_TOOLS_VERSION}"
dch -r ""

# Build the Debian package
export DISTRIB="$(lsb_release -cs)"
debuild -eDISTRIB -eSECTION -eLIBNVIDIA_CONTAINER_TOOLS_VERSION -eVERSION="${REVISION}" \
  --dpkg-buildpackage-hook='sh debian/prepare' -i -us -uc -b

# Move the resulting .deb package to /dist
mv /tmp/*.deb /dist

# Install the package
dpkg -i /dist/*.deb

echo "Installation completed successfully."