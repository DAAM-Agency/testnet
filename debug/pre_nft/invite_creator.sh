# Invite Admin & Accept
echo "========= Invite Creator ========="
for user in $@
do
    echo "Inviting: "$user
    flow transactions send ./transactions/admin/invite_creator.cdc $user --signer agent
done
