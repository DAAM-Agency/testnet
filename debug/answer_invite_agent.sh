# Agent
echo -n "Verify Agent Status: "
flow scripts execute ./scripts/is_agent.cdc $AGENT
echo -n "Verify Agent2 Status: "
flow scripts execute ./scripts/is_agent.cdc $AGENT2

echo "---------- Answering Agents ----------"
for user in agent agent2
do
echo -n $user
flow transactions send ./transactions/admin/answer_agent_invite.cdc $2 --signer $user
done

echo -n "Verify Agent Status: "
flow scripts execute ./scripts/is_agent.cdc $AGENT
echo -n "Verify Agent2 Status: "
flow scripts execute ./scripts/is_agent.cdc $AGENT2
