#!/bin/bash

# Called by "Release_Pipeline", the build pipeline for official releases
# Detect official release type (alpha, beta or final) and set version string
# One, and only one, tag in the form "luxcorerender_v*" is needed, 
# otherwise the official release build aborts.

if [[ $RELEASE_BUILD == "TRUE" ]] ; then
    echo "This is an official release build"
    echo "Commit ID: $BUILD_SOURCEVERSION"
    TAGS=$(git tag --points-at $BUILD_SOURCEVERSION)
    for tag in $TAGS
    do
        if [[ $tag != "latest" ]] && [[ $tag == "luxcorerender_v"* ]] ; then
            if [[ -z "$VERSION_STRING" ]] ; then
                VERSION_STRING=$(echo $tag | cut -d'_' -f 2)
            else
                echo "Multiple git tags identify different versions, aborting..."
                exit 1
            fi
        fi
    done
fi

echo "$VERSION_STRING"
if [[ -z "$VERSION_STRING" ]] ; then
    echo "No suitable git tag found"
    echo "For an official release, a tag in the form 'luxcorerender_v*' is needed"
    exit 1
fi

if [[ $VERSION_STRING == *"alpha"* ]] || \
   [[ $VERSION_STRING == *"beta"* ]] || \
   [[ $VERSION_STRING == "latest" ]] ; then
    FINAL="FALSE"
else
    FINAL="TRUE"
fi

# make FINAL and VERSION_STRING variables available for other pipeline jobs
echo "##vso[task.setvariable variable=final;isOutput=true]$FINAL"
echo "##vso[task.setvariable variable=version_string;isOutput=true]$VERSION_STRING"
