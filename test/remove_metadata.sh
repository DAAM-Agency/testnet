# Remove Metadata [MID]
echo "========= Remove Metadata Submission ========="
flow transactions send ./transactions/creator/remove_submission.cdc 3 --signer creator  #C MID 3 

echo "========= Veriy Metadata ========="
# verify metadata
flow scripts execute ./scripts/metadata/get_metadata_list.cdc $CREATOR 
flow scripts execute ./scripts/metadata/get_metadata_list.cdc $CREATOR2 

# Remove Metadata [MID]
echo "========= Remove Metadata Submission ========="
flow transactions send ./transactions/creator/remove_submission.cdc $1 --signer $2

echo "========= Veriy Metadata ========="
# verify metadata
flow scripts execute ./scripts/metadata/get_metadata_list.cdc $CREATOR 
flow scripts execute ./scripts/metadata/get_metadata_list.cdc $CREATOR2