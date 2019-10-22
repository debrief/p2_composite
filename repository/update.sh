#!/usr/bin/env bash

folder='.'
updates="updates"

function findZipFile {
    echo $(find $folder -name *.zip |head -1)
}

function checkPresent {
    if [ ! -f "$1" ]; then
        echo "$1 is missing"
        is_fault=1
    fi
}

function checkFolder {
    checkPresent "$folder/compositeContent.xml"
    checkPresent "$folder/compositeArtifacts.xml"
    checkPresent "$folder/p2.index"
    if [ $is_fault = 0  ]; then
        zipFile="$(findZipFile)"
        if [ "_$zipFile" = "_" ]; then
            echo "Zip-file not found in folder"
            is_fault=1
        fi
    fi
}

function getDTG {
    echo $(date '+%Y_%m_%d__%H_%M_%S')
}

function updateChildren {
    file=$1
    dt=$2

    count=$(($(grep '<child[[:space:]+]location' "$file" |wc -l)+1))
    sed "s/<children[[:space:]+]size=.*[\'\"]/<children size='$count'/" <"$file" \
        | sed "s/<\/children>/  <child location='$updates\/$dt' \/>\n  <\/children>/" \
        >"$file.new"
    mv "$file.new" "$file"    
}

function unpackZip {
    mkdir -p "$updates"
    unzip "$1" -d "$updates/$2" >/dev/null
}

# do some checks on this folder
# 1. check things are ok

is_fault=0
checkFolder
if [ $is_fault = 0 ]; then
    echo "Valid folder, doing update"
    dtg=$(getDTG)
    newName="$folder/$dtg.zip"

    # rename file
    echo "Renaming zip file with DTG"
    mv -f "$zipFile" "$newName"

    echo "Updating XML metadata"

    # parse category files
    updateChildren "$folder/compositeContent.xml" $dtg
    updateChildren "$folder/compositeArtifacts.xml" $dtg

    echo "Unpacking repository"

    # unpack the zip into the updates folder

    unpackZip "$newName" "$dtg"

    echo "Deleting .zip file"

    # lastly, delete the zip file
    rm -f "$newName"

    echo "== COMPLETE =="
fi
