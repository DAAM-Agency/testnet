# Remove Creator
echo -n "Verify Creator Status: "
flow scripts execute ./scripts/is_creator.cdc $1

echo "FAIL TEST: Attempting to Remove Creator by non-Admin"
flow transactions send ./transactions/admin/remove_creator.cdc $1 --signer client

echo "---------- Remove Creator ----------"
flow transactions send ./transactions/admin/remove_creator.cdc $1 --signer cto

echo -n "Verify Creator Status: "
flow scripts execute ./scripts/is_creator.cdc $1

# Delete / Reset Addresses
flow transactions send ./transactions/tools/delete_creator.cdc --signer creator
