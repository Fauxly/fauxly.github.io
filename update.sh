#!/bin/bash

echo "Cleaning old package indexes..."

rm -f Packages
rm -f Packages.gz

echo "Scanning all DEB packages..."

dpkg-scanpackages -m ./debs /dev/null > Packages

echo "Compressing Packages..."

gzip -kf Packages

echo "Generating Release file..."

cat > Release << EOF
Origin: Fauxly Repo
Label: Fauxly Repo
Suite: stable
Version: 1.0
Codename: tvos
Architectures: appletvos-arm64
Components: main
Description: Fauxly Apple TV Repository
EOF

echo "Generating SHA256 hashes..."

SHA256_PACKAGES=$(shasum -a 256 Packages | awk '{ print $1 }')
SHA256_GZ=$(shasum -a 256 Packages.gz | awk '{ print $1 }')

SIZE_PACKAGES=$(stat -f%z Packages)
SIZE_GZ=$(stat -f%z Packages.gz)

cat >> Release << EOF

SHA256:
 $SHA256_PACKAGES $SIZE_PACKAGES Packages
 $SHA256_GZ $SIZE_GZ Packages.gz
EOF

echo "Done. Repository updated."
