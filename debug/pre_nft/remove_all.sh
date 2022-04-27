# Remove Admin
echo -n "Verify Admin Status: "
flow scripts execute ./scripts/is_admin.cdc $ADMIN
echo -n "Verify Admin2 Status: "
flow scripts execute ./scripts/is_admin.cdc $ADMIN2

echo "---------- Get 1 of 3 Admin Votes ----------"
flow transactions send ./transactions/admin/remove_admin.cdc $ADMIN --signer admin

echo "FAIL TEST: Removing Admin: Not Admin"
flow transactions send ./transactions/admin/remove_admin.cdc $ADMIN --signer client

echo "---------- Get 2 of 3 Admin Votes ----------"
flow transactions send ./transactions/admin/remove_admin.cdc $ADMIN --signer admin2

echo "---------- Get 3 of 3 CTO Votes ----------"
flow transactions send ./transactions/admin/remove_admin.cdc $ADMIN --signer cto

echo -n "Verify Admin Status: "
flow scripts execute ./scripts/is_admin.cdc $ADMIN
echo -n "Verify Admin2 Status: "
flow scripts execute ./scripts/is_admin.cdc $ADMIN2

flow transactions send ./transactions/tools/delete_admin.cdc --signer admin

# Remove Creator
echo -n "Verify Creator Status: "
flow scripts execute ./scripts/is_creator.cdc $CREATOR
echo -n "Verify Creator2 Status: "
flow scripts execute ./scripts/is_creator.cdc $CREATOR2

echo "FAIL TEST: Attempting to Remove Creator by non-Admin"
flow transactions send ./transactions/admin/remove_creator.cdc $CREATOR --signer client

echo "---------- Remove Creator ----------"
flow transactions send ./transactions/admin/remove_creator.cdc $CREATOR --signer cto

echo "---------- Remove Creator2 ----------"
flow transactions send ./transactions/admin/remove_creator.cdc $CREATOR2 --signer cto

echo -n "Verify Creator Status: "
flow scripts execute ./scripts/is_creator.cdc $CREATOR
echo -n "Verify Creator2 Status: "
flow scripts execute ./scripts/is_creator.cdc $CREATOR2

# Delete / Reset Addresses
flow transactions send ./transactions/tools/delete_creator.cdc --signer creator
flow transactions send ./transactions/tools/delete_creator.cdc --signer creator2

# Remove Agent
echo -n "Verify Agent Status: "
flow scripts execute ./scripts/is_agent.cdc $AGENT
echo -n "Verify Agent2 Status: "
flow scripts execute ./scripts/is_agent.cdc $AGENT2

echo "FAIL TEST: Attempting to Remove Agent by non-Admin"
flow transactions send ./transactions/admin/remove_agent.cdc $AGENT --signer client

echo "---------- Remove Agent ----------"
flow transactions send ./transactions/admin/remove_agent.cdc $AGENT --signer cto

echo "---------- Remove Agent ----------"
flow transactions send ./transactions/admin/remove_agent.cdc $AGENT2 --signer cto

echo -n "Verify Agent Status: "
flow scripts execute ./scripts/is_agent.cdc $AGENT
echo -n "Verify Agent2 Status: "
flow scripts execute ./scripts/is_agent.cdc $AGENT2
