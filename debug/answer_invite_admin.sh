# Invite Admin & Accept
echo "========= Invite Admins, Agents, & Creator ========="
# Admin
echo -n "Verify Admin Status: "
flow scripts execute ./scripts/is_admin.cdc $ADMIN
echo -n "Verify Admin2 Status: "
flow scripts execute ./scripts/is_admin.cdc $ADMIN2

echo "---------- Answering Admins ----------"
for user in admin admin2
do
echo -n $user
flow transactions send ./transactions/admin/answer_admin_invite.cdc $1 --signer $user
done

echo -n "Verify Admin Status: "
flow scripts execute ./scripts/is_admin.cdc $ADMIN
echo -n "Verify Admin2 Status: "
flow scripts execute ./scripts/is_admin.cdc $ADMIN2
