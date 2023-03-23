# Invite Admin & Accept
echo "========= Invite Creator ========="
flow transactions send ./transactions/admin/invite_creator.cdc $CREATOR  0.21 --signer agent
flow transactions send ./transactions/admin/invite_creator.cdc $CREATOR2 0.11 --signer agent2
 