# Invite Admin & Accept
echo "========= Invite Creator ========="

echo "---------- Inviting Creators ----------"
for user in $CREATOR $CREATOR2
do
getAddressName $user
flow transactions send ./transactions/admin/invite_creator.cdc $user --signer agent
done
