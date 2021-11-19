# Remove Metadata [MID]
# $1 is MID
# $2 is signer aka creator or creator2

# Verify metadata
echo "========= Veriy Metadata ========="
echo -n "Creator: "
flow scripts execute ./scripts/metadata/get_metadata_list.cdc $CREATOR 
echo -n "Creator2: "
flow scripts execute ./scripts/metadata/get_metadata_list.cdc $CREATOR2 

echo "========= Remove Metadata Submission ========="
flow transactions send ./transactions/creator/remove_submission.cdc $1 --signer $2

# Verify metadata
echo "========= Veriy Metadata ========="
echo -n "Creator: "
flow scripts execute ./scripts/metadata/get_metadata_list.cdc $CREATOR 
echo -n "Creator2: "
flow scripts execute ./scripts/metadata/get_metadata_list.cdc $CREATOR2 