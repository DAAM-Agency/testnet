# Remove Agent
echo -n "Verify Agent Status: "
flow scripts execute ./scripts/is_agent.cdc $1

echo "FAIL TEST: Attempting to Remove Agent by non-Admin"
flow transactions send ./transactions/admin/remove_agent.cdc $1 --signer client

echo "---------- Remove Agent ----------"
flow transactions send ./transactions/admin/remove_agent.cdc $1 --signer cto

echo -n "Verify Agent Status: "
flow scripts execute ./scripts/is_agent.cdc $1
