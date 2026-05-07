#!/bin/bash

echo "Cleaning old repository files..."

rm -f Packages
rm -f Packages.gz
rm -f Packages.bz2
rm -f Release

echo "Generating Packages..."

dpkg-scanpackages -m ./debs /dev/null > Packages

echo "Compressing Packages..."

gzip -kf Packages
bzip2 -kf Packages

echo "Calculating file sizes..."

SIZE_PACKAGES=$(stat -f%z Packages)
SIZE_GZ=$(stat -f%z Packages.gz)
SIZE_BZ2=$(stat -f%z Packages.bz2)

echo "Generating SHA256 hashes..."

SHA256_PACKAGES=$(shasum -a 256 Packages | awk '{ print $1 }')
SHA256_GZ=$(shasum -a 256 Packages.gz | awk '{ print $1 }')
SHA256_BZ2=$(shasum -a 256 Packages.bz2 | awk '{ print $1 }')

echo "Creating Release file..."

cat > Release << EOF
Origin: Fauxly Repo
Label: Fauxly Repo
Suite: stable
Version: 1.0
Codename: tvos
Architectures: appletvos-arm64
Components: main
Description: Fauxly Apple TV Repository

SHA256:
 $SHA256_PACKAGES $SIZE_PACKAGES Packages
 $SHA256_GZ $SIZE_GZ Packages.gz
 $SHA256_BZ2 $SIZE_BZ2 Packages.bz2
EOF

echo "Repository updated successfully."