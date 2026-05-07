dpkg-scanpackages -m ./debs > Packages
gzip -c Packages > Packages.gz

cd beta

dpkg-scanpackages -m ./debs > Packages
gzip -c Packages > Packages.gz

cd ..
