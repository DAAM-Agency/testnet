# Agent
echo -n "Verify Agent Status: "
flow scripts execute ./scripts/is_agent.cdc $3

echo "---------- Answering Agents ----------"
flow transactions send ./transactions/answer/answer_agent_invite.cdc $2 --signer $1

echo -n "Verify Agent Status: "
flow scripts execute ./scripts/is_agent.cdc $3
