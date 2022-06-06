# Remove Metadata [MID]
# $1 is MID
# $2 is signer aka creator or creator2

# Verify Metadata
echo "========= Verify Metadata ========="
for user in $CREATOR $CREATOR2
do
    METADATA=$(flow -o json scripts execute ./scripts/get_mids.cdc $user | jq ' .value' | grep value | awk '{print $2}' | tr -d '"')
    #echo "Metadata: "$METADATA
    for list in $METADATA
    do
        flow scripts execute ./scripts/view_metadata.cdc $user $list
    done
done

echo "========= Remove Metadata Submission ========="
flow transactions send ./transactions/creator/remove_submission.cdc $2 --signer $1
export REMOVED_METADATA=$2

# Verify Metadata
echo "========= Verify Metadata ========="
for user in $CREATOR $CREATOR2
do
    METADATA=$(flow -o json scripts execute ./scripts/get_mids.cdc $user | jq ' .value' | grep value | awk '{print $2}' | tr -d '"')
    #echo "Metadata: "$METADATA
    for list in $METADATA
    do
        flow scripts execute ./scripts/view_metadata.cdc $user $list
    done
done