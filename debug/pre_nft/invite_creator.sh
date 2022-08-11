# Invite Admin & Accept
echo "========= Invite Creator ========="
for user in $CREATOR $CREATOR2
do
    echo "Inviting: "$user
    flow transactions send ./transactions/admin/invite_creator.cdc $user 0.21 --signer agent
done
