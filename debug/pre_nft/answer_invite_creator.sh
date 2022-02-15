#Creator
echo -n "Verify Creator Status: "
flow scripts execute ./scripts/is_creator.cdc $1

echo "---------- Answering Creators ----------"
flow transactions send ./transactions/answer/answer_creator_invite.cdc true --signer $1

echo -n "Verify Creator Status: "
flow scripts execute ./scripts/is_creator.cdc $1
