#! /bin/bash
#
# Renames all NetCDF files beginning with $ORIG_PREFIX in the $NC_ROOT
# directory with the $NEW_PREFIX name.
#
# ============================================================================
# $RCSfile$
# $Source$
# $Revision$
# $Date$
# $Author$
# $Name$
# ============================================================================
#

PATH=/usr/bin:/bin;

# Path to netcdf files
NC_ROOT='/home/codaradm/data/totals/maracoos/oi/nc/5MHz';
# Current file prefix 
ORIG_PREFIX='OI_MARA_';
# New file prefix
NEW_PREFIX='RU_5MHz_';

# Make sure the directory exists
if [ ! -d "$NC_ROOT" ]
then
    echo "Invalid NC_ROOT: $NC_ROOT"; >&2;
    exit 1;
fi

# Search for all NetCDF files that start with $ORIG_PREFIX
origFiles=$(find $NC_ROOT -name "${ORIG_PREFIX}*\.nc");
[ -z "$origFiles" ] && exit 0

# Rename each file with the new prefix name
for oldFile in $origFiles
do
    echo "OLD: $oldFile";
    oldName=$(basename $oldFile);
    [ "$?" -ne 0 ] && continue;

    newName=$(echo $oldName | sed "{s/$ORIG_PREFIX/$NEW_PREFIX/}");

    newFile="${NC_ROOT}/${newName}";
    echo "NEW: $newFile";

    mv $oldFile $newFile;

    if [ "$?" -ne 0 ]
    then
        echo "Error moving $oldFile...aborting with no further renames" >&2;
        exit 0;
    fi

done

