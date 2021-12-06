# Invite Admin & Accept
echo "========= Invite Admins, Agents, & Creator ========="
# Admin
echo -n "Verify Admin Status: "
flow scripts execute ./scripts/is_admin.cdc $1

echo "---------- Answering Admins ----------"
flow transactions send ./transactions/admin/answer_admin_invite.cdc $1 --signer cto

echo -n "Verify Admin Status: "
flow scripts execute ./scripts/is_admin.cdc $1
