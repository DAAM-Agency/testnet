# Dis/Approve the Metadatas [MID, Status]
echo "========= Approve Metadata Submissions ========="
flow transactions send ./transactions/admin/change_metadata_status.cdc 1 true --signer admin   # MID 1
flow transactions send ./transactions/admin/change_metadata_status.cdc 2 true --signer admin2  # MID 2
flow transactions send ./transactions/admin/change_metadata_status.cdc 3 true --signer admin2  # MID 3
flow transactions send ./transactions/admin/change_metadata_status.cdc 4 true --signer admin2  # MID 4
flow transactions send ./transactions/admin/change_metadata_status.cdc 5 true --signer admin2  # MID 5
flow transactions send ./transactions/admin/change_metadata_status.cdc 6 true --signer admin2  # MID 6
flow transactions send ./transactions/admin/change_metadata_status.cdc 7 true --signer admin2  # MID 7
flow transactions send ./transactions/admin/change_metadata_status.cdc 8 true --signer admin2  # MID 8
flow transactions send ./transactions/admin/change_metadata_status.cdc 9 true --signer admin2  # MID 9

if [$1 != null]
then
    flow transactions send ./transactions/admin/change_metadata_status.cdc $1 false --signer admin2  # MID x
fi

