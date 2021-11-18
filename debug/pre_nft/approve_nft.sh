# Dis/Approve the Metadatas [MID, Status]
echo "========= Approve Metadata Submissions ========="
flow transactions send ./transactions/admin/change_metadata_status.cdc 1 true --signer cto  # MID 1
flow transactions send ./transactions/admin/change_metadata_status.cdc 2 true --signer cto  # MID 2
flow transactions send ./transactions/admin/change_metadata_status.cdc 3 true --signer cto  # MID 3
flow transactions send ./transactions/admin/change_metadata_status.cdc 4 true --signer cto  # MID 4
flow transactions send ./transactions/admin/change_metadata_status.cdc 5 true --signer cto  # MID 5
flow transactions send ./transactions/admin/change_metadata_status.cdc 6 true --signer cto  # MID 6
flow transactions send ./transactions/admin/change_metadata_status.cdc 7 true --signer cto  # MID 7
flow transactions send ./transactions/admin/change_metadata_status.cdc 8 true --signer cto  # MID 8
flow transactions send ./transactions/admin/change_metadata_status.cdc 9 true --signer cto  # MID 9

if [$1 != null]
then
    flow transactions send ./transactions/admin/change_metadata_status.cdc $1 false --signer cto  # MID x
fi
