#!/bin/bash
# Change Copyright [MID, Status*] *0=Fraud, 1=Claim, 2=Unverified, 3=Verfied

echo "========== Change Copyright Status =========="
for mid in {1..9}
do
    if [ $mid == $REMOVED_METADATA ]
    then
        echo "FAIL TEST: Metadata Disapproved & Removed."
    fi

    echo "mid: $mid"
    flow transactions send ./transactions/admin/change_copyright.cdc $mid 3 --signer cto #A Verfied
done

if [$1 && $2 != null]
then
    flow transactions send ./transactions/admin/change_copyright.cdc $2 $1 --signer cto #I Verfied
fi
