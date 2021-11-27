# Remove Admin
echo -n "Verify Admin Status: "
flow scripts execute ./scripts/is_admin.cdc $1

echo "---------- Get 1 of 2 Admin Votes ----------"
flow transactions send ./transactions/admin/remove_admin.cdc $ADMIN2 --signer cto

echo "FAIL TEST: Removing Admin: Not Admin"
flow transactions send ./transactions/admin/remove_admin.cdc $ADMIN2 --signer client

echo "---------- Get 2 of 2 Admin Votes ----------"
if $1 == $ADMIN
then
flow transactions send ./transactions/admin/remove_admin.cdc $ADMIN2 --signer admin2
fi

if $1 == $ADMIN2
then
flow transactions send ./transactions/admin/remove_admin.cdc $ADMIN2 --signer admin
fi

echo -n "Verify Admin Status: "
flow scripts execute ./scripts/is_admin.cdc $1

flow transactions send ./transactions/tools/delete_admin.cdc --signer $1
