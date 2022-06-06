# Invite Admin & Accept
echo "========= Invite Admins ========="
for user in $@
do
    echo "Inviting: "$user
    flow transactions send ./transactions/admin/invite_admin.cdc $user --signer cto
done
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc