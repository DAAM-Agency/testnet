#!/bin/bash
# Dis/Approve the Metadatas [MID, Status]
echo "========= Approve Metadata Submissions ========="
for mid in {1..9}
do
    if [ $(($mid == $REMOVED_METADATA)) == 1 ]; then
        echo "FAIL TEST: Metadata Disapproved & Removed."
    fi

    echo "mid: $mid"

    if [ $(($mid == $1)) == 1 ]; then
        echo "DISAPPROVED Metadata"
        DISAPPROVED_METADTA=$1
        flow transactions send ./transactions/admin/change_metadata_status.cdc $mid false --signer cto  # MID x
    else
        echo "APPROVED Metadata"
        flow transactions send ./transactions/admin/change_metadata_status.cdc $mid true --signer cto
    fi
done


