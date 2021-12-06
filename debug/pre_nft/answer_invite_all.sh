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
flow transactions send ./transactions/answer_admin_invite.cdc true --signer admin
flow transactions send ./transactions/answer_admin_invite.cdc true --signer admin2

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
flow transactions send ./transactions/answer_agent_invite.cdc true --signer agent
flow transactions send ./transactions/answer_agent_invite.cdc true --signer agent2

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
flow transactions send ./transactions/answer_creator_invite.cdc true --signer creator
flow transactions send ./transactions/answer_creator_invite.cdc true --signer creator2

echo -n "Verify Creator Status: "
flow scripts execute ./scripts/is_creator.cdc $CREATOR
echo -n "Verify Creator2 Status: "
flow scripts execute ./scripts/is_creator.cdc $CREATOR2
