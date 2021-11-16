# Remove Admin
echo -n "Verify Admin Status: "
flow scripts execute ./scripts/is_admin.cdc $ADMIN
echo -n "Verify Admin2 Status: "
flow scripts execute ./scripts/is_admin.cdc $ADMIN2

echo "---------- Get 1 of 2 Admin Votes ----------"
flow transactions send ./transactions/admin/remove_admin.cdc $ADMIN2 --signer admin

echo "FAIL TEST: Removing Admin: Not Admin"
flow transactions send ./transactions/admin/remove_admin.cdc $ADMIN2 --signer client

echo "---------- Get 2 of 2 Admin Votes ----------"
flow transactions send ./transactions/admin/remove_admin.cdc $ADMIN2 --signer admin2

echo -n "Verify Admin Status: "
flow scripts execute ./scripts/is_admin.cdc $ADMIN
echo -n "Verify Admin2 Status: "
flow scripts execute ./scripts/is_admin.cdc $ADMIN2

flow transactions send ./transactions/admin/delete_admin.cdc --signer admin2

# Remove Creator
echo -n "Verify Creator Status: "
flow scripts execute ./scripts/is_creator.cdc $CREATOR
echo -n "Verify Creator2 Status: "
flow scripts execute ./scripts/is_creator.cdc $CREATOR2

echo "FAIL TEST: Attempting to Remove Creator by non-Admin"
flow transactions send ./transactions/admin/remove_creator.cdc $CREATOR --signer client

echo "---------- Remove Creator ----------"
flow transactions send ./transactions/admin/remove_creator.cdc $CREATOR --signer cto

echo -n "Verify Creator Status: "
flow scripts execute ./scripts/is_creator.cdc $1

# Delete / Reset Addresses
flow transactions send ./transactions/creator/delete_creator.cdc --signer creator
