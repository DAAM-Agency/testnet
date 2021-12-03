#!/bin/bash
# Dis/Approve the Metadatas [MID, Status]
echo "========= Approve Metadata Submissions ========="
for mid in {1..9}
do
    if [ $mid == $REMOVED_METADATA ]
    then
        echo "FAIL TEST: Metadata Disapproved & Removed."
    fi

    echo "mid: $mid"
    flow transactions send ./transactions/admin/change_metadata_status.cdc $mid true --signer cto
done

if [$1 != null]
then
    flow transactions send ./transactions/admin/change_metadata_status.cdc $1 false --signer cto  # MID x
fi
