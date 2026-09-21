#!/bin/bash

set -e

name="$(
  basename "$(
    pwd
  )"
)"
dist="`echo "$name" | grep -o '\.el[6-9][_0-9]*'`"
major="${dist:3:1}"

rm -rf rpmbuild
mkdir rpmbuild
ln -s ../SOURCES rpmbuild/SOURCES
ln -s ../SPECS rpmbuild/SPECS

pkgname="`rpmspec --srpm --define '_topdir '$(pwd)/rpmbuild --define "dist $dist" --qf "%{name}\n"    -q SPECS/*.spec`"
version="`rpmspec --srpm --define '_topdir '$(pwd)/rpmbuild --define "dist $dist" --qf "%{version}\n" -q SPECS/*.spec`"
release="`rpmspec --srpm --define '_topdir '$(pwd)/rpmbuild --define "dist $dist" --qf "%{release}\n" -q SPECS/*.spec`"

echo '[version]' $version-$release

packages="packages/`date +%s`"

rpmbuild --define '_topdir '`pwd`/rpmbuild --define "dist $dist" -bs rpmbuild/SPECS/*spec

for arch in x86_64; do
  mkdir -p "$packages"/"${arch}"
  /usr/bin/mock -r rocky+epel-"${major}"-"${arch}" \
      --define "dist $dist" \
      --rebuild rpmbuild/SRPMS/"${pkgname}-${version}-${release}.src.rpm" \
    && mv -i /var/lib/mock/rocky+epel-"${major}"-"${arch}"/result/*.rpm "$packages"/"${arch}"/
done

echo "built packages are in `pwd`/$packages/"
