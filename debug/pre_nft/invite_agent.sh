# Invite Admin & Accept
echo "========= Invite Agents ========="

echo "---------- Inviting Agents ----------"
for user in $AGENT $AGENT2
do
getAddressName $user
flow transactions send ./transactions/admin/invite_agent.cdc $user --signer cto
done
