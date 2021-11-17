# Invite Admin & Accept
# Argument #1: Admins Accept/Decline (Bool)
# Argument #2: Agencts Accept/Decline (Bool)
# Argument #3: Creators Accept/Decline (Bool)

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
flow transactions send ./transactions/answer_admin_invite.cdc $1 --signer $user
done

echo -n "Verify Admin Status: "
flow scripts execute ./scripts/is_admin.cdc $ADMIN
echo -n "Verify Admin2 Status: "
flow scripts execute ./scripts/is_admin.cdc $ADMIN2

# Agent
echo -n "Verify Agent Status: "
flow scripts execute ./scripts/is_agent.cdc $AGENT
echo -n "Verify Agent2 Status: "
flow scripts execute ./scripts/is_agent.cdc $AGENT2

echo "---------- Answering Agents ----------"
for user in agent agent2
do
echo -n $user
flow transactions send ./transactions/answer_agent_invite.cdc $2 --signer $user
done

echo -n "Verify Agent Status: "
flow scripts execute ./scripts/is_agent.cdc $AGENT
echo -n "Verify Agent2 Status: "
flow scripts execute ./scripts/is_agent.cdc $AGENT2

#Creator
echo -n "Verify Creator Status: "
flow scripts execute ./scripts/is_creator.cdc $CREATOR
echo -n "Verify Creator2 Status: "
flow scripts execute ./scripts/is_creator.cdc $CREATOR2

echo "---------- Answering Creators ----------"
for user in creator creator2
do
echo -n $user
flow transactions send ./transactions/answer_creator_invite.cdc $3 --signer $user
done

echo -n "Verify Creator Status: "
flow scripts execute ./scripts/is_creator.cdc $CREATOR
echo -n "Verify Creator2 Status: "
flow scripts execute ./scripts/is_creator.cdc $CREATOR2
