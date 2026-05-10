#!/bin/bash

echo "Cleaning old repository files..."

rm -f Packages
rm -f Packages.gz
rm -f Release
rm -f Packages.new

echo "Generating Packages..."

dpkg-scanpackages -m ./debs /dev/null > Packages

echo "Adding icons to Packages..."

REPO_URL="https://fauxly.github.io"

while IFS= read -r line; do

    echo "$line" >> Packages.new

    if [[ $line == Package:* ]]; then
        PACKAGE=$(echo "$line" | awk '{print $2}')
    fi

    if [[ $line == Filename:* ]]; then

        if [ -f "icons/$PACKAGE.png" ]; then
            ICON_URL="$REPO_URL/icons/$PACKAGE.png"
            echo "Icon: $ICON_URL" >> Packages.new
        fi

    fi

done < Packages

mv Packages.new Packages

echo "Compressing Packages..."

gzip -kf Packages

echo "Calculating file sizes..."

SIZE_PACKAGES=$(stat -f%z Packages)
SIZE_GZ=$(stat -f%z Packages.gz)

echo "Generating MD5 hashes..."

MD5_PACKAGES=$(md5 -q Packages)
MD5_GZ=$(md5 -q Packages.gz)

echo "Generating SHA1 hashes..."

SHA1_PACKAGES=$(shasum Packages | awk '{ print $1 }')
SHA1_GZ=$(shasum Packages.gz | awk '{ print $1 }')

echo "Generating SHA256 hashes..."

SHA256_PACKAGES=$(shasum -a 256 Packages | awk '{ print $1 }')
SHA256_GZ=$(shasum -a 256 Packages.gz | awk '{ print $1 }')

echo "Creating Release file..."

cat > Release << EOF
Origin: Fauxly
Label: Fauxly tvOS Repo
Suite: stable
Version: 1.0
Codename: Fauxly
Architectures: darwin-arm64, appletvos-arm64
Components: main
Description: Fauxly Apple TV Repository

MD5Sum:
 $MD5_PACKAGES $SIZE_PACKAGES Packages
 $MD5_GZ $SIZE_GZ Packages.gz

SHA1:
 $SHA1_PACKAGES $SIZE_PACKAGES Packages
 $SHA1_GZ $SIZE_GZ Packages.gz

SHA256:
 $SHA256_PACKAGES $SIZE_PACKAGES Packages
 $SHA256_GZ $SIZE_GZ Packages.gz
EOF

echo "Repository updated successfully."
