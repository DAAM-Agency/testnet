# Invite Admin & Accept
echo "========= Invite Admins, Agents, & Creator ========="

echo "---------- Inviting Admins ----------"
for user in $ADMIN $ADMIN2
do
flow transactions send ./transactions/admin/invite_admin.cdc $user --signer cto
done

echo "---------- Inviting Agents ----------"
for user in $AGENT $AGENT2
do
flow transactions send ./transactions/admin/invite_agent_minter.cdc $user true --signer cto
done

echo "---------- Inviting Creators ----------"
for user in $CREATOR $CREATOR2
do
flow transactions send ./transactions/admin/invite_creator.cdc $user 0.14 --signer cto
done
flow transactions send ./transactions/send_flow_em.cdc 1.0 $PROFILE  # dummy action update bc
