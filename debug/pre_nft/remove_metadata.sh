# Remove Metadata [MID]
# $1 is MID
# $2 is signer aka creator or creator2

# Verify Metadata
echo "========= Verify Metadata ========="
for user in $CREATOR $CREATOR2
do
    flow -o json scripts execute ./scripts/get_mids.cdc $user | jq ' .value' 
done

echo "========= Remove Metadata Submission ========="
flow transactions send ./transactions/creator/remove_submission.cdc $2 --signer $1
export REMOVED_METADATA=$2

# Verify Metadata
echo "========= Verify Metadata ========="
for user in $CREATOR $CREATOR2
do
    flow -o json scripts execute ./scripts/get_mids.cdc $user | jq ' .value' 
done