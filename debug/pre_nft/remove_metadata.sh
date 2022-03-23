# Remove Metadata [MID]
# $1 is MID
# $2 is signer aka creator or creator2

echo "========= Verify Metadata ========="
# verify metadata
echo -n "Creator: "
flow transactions send ./transactions/admin/Get_metadatas_ref.cdc $CREATOR --signer admin
echo -n "Creator2: "
flow transactions send ./transactions/admin/Get_metadatas_ref.cdc $CREATOR2 --signer admin

echo "========= Remove Metadata Submission ========="
flow transactions send ./transactions/creator/remove_submission.cdc $2 --signer $1
export REMOVED_METADATA=$2

echo "========= Verify Metadata ========="
# verify metadata
echo -n "Creator: "
flow transactions send ./transactions/admin/Get_metadatas_ref.cdc $CREATOR --signer admin
echo -n "Creator2: "
flow transactions send ./transactions/admin/Get_metadatas_ref.cdc $CREATOR2 --signer admin