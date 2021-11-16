# Invite Admin & Accept
echo "========= Invite Admins ========="

echo "---------- Inviting Admins ----------"
for user in $ADMIN $ADMIN2
do
getAddressName $user
flow transactions send ./transactions/admin/invite_admin.cdc $user --signer cto
done