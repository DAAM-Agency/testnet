# Invite Admin & Accept
echo "========= Invite Admins, Agents, & Creator ========="

echo "---------- Inviting Admins ----------"
for user in $ADMIN $ADMIN2
do
getAddressName $user
flow transactions send ./transactions/admin/invite_admin.cdc $user --signer cto
done

echo "---------- Inviting Agents ----------"
for user in $AGENT $AGENT2
do
getAddressName $user
flow transactions send ./transactions/admin/invite_agent.cdc $user --signer cto
done

echo "---------- Inviting Creators ----------"
for user in $CREATOR $CREATOR2
do
getAddressName $user
flow transactions send ./transactions/admin/invite_creator.cdc $user --signer cto
done
