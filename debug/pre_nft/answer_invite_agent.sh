# Agent
echo -n "Verify Agent Status: "
flow scripts execute ./scripts/is_agent.cdc $1

echo "---------- Answering Agents ----------"
flow transactions send ./transactions/answer/answer_agent_invite.cdc $1 --signer cto

echo -n "Verify Agent Status: "
flow scripts execute ./scripts/is_agent.cdc $12
