# Remove Metadata [MID]
# $1 is MID
# $2 is signer aka creator or creator2

# Verify metadata
echo "========= Veriy Metadata ========="
echo -n "Creator: "
flow scripts execute ./scripts/wallet/get_tokenIds.cdc $CREATOR 
echo -n "Creator2: "
flow scripts execute ./scripts/wallet/get_tokenIds.cdc $CREATOR2 

echo "========= Remove Metadata Submission ========="
flow transactions send ./transactions/creator/remove_submission.cdc $2 --signer $1
export REMOVED_METADATA=$2

# Verify metadata
echo "========= Veriy Metadata ========="
echo -n "Creator: "
flow scripts execute ./scripts/wallet/get_tokenIds.cdc $CREATOR 
echo -n "Creator2: "
flow scripts execute ./scripts/wallet/get_tokenIds.cdc $CREATOR2 