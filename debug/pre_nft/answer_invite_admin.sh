# Invite Admin & Accept
# Admin
echo -n "Verify Admin Status: "
flow scripts execute ./scripts/is_admin.cdc $3

echo "---------- Answering Admins ----------"
flow transactions send ./transactions/answer/answer_admin_invite.cdc $2 --signer $1

echo -n "Verify Admin Status: "
flow scripts execute ./scripts/is_admin.cdc $3
