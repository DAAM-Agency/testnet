# Remove Metadata [MID]
# $1 is MID
# $2 is signer aka creator or creator2

# Verify metadata
echo "========= Veriy Metadata ========="
echo -n "Creator: "
flow scripts execute ./scripts/daam_wallet/get_tokenIDs.cdc $CREATOR 
echo -n "Creator2: "
flow scripts execute ./scripts/daam_wallet/get_tokenIDs.cdc $CREATOR2 

echo "========= Remove Metadata Submission ========="
flow transactions send ./transactions/creator/remove_submission.cdc $2 --signer $1
export REMOVED_METADATA=$2

# Verify metadata
echo "========= Veriy Metadata ========="
echo -n "Creator: "
flow scripts execute ./scripts/daam_wallet/get_tokenIDs.cdc $CREATOR 
echo -n "Creator2: "
flow scripts execute ./scripts/daam_wallet/get_tokenIDs.cdc $CREATOR2 