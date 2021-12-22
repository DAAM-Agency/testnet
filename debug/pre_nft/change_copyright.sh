#!/bin/bash
# Change Copyright [MID, Status*] *0=Fraud, 1=Claim, 2=Unverified, 3=Verfied

echo "========== Change Copyright Status =========="
for mid in {1..9}
do
    if [ $(($mid == $REMOVED_METADATA)) == 1 ]; then
        echo "FAIL TEST: Metadata Disapproved & Removed."
    fi

    echo "mid: $mid"

    if [ $(($mid == $1)) == 1 ]; then
        echo "DISAPPROVED Copyright"
        DISAPPROVED_COPYRIGHT=$1
        flow transactions send ./transactions/admin/change_copyright.cdc $1 0 --signer cto #Verfied
    else
        echo "APPROVED Copyright"
        flow transactions send ./transactions/admin/change_copyright.cdc $mid 3 --signer cto #Fraud
    fi
done


