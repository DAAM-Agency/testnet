#Creator
echo -n "Verify Creator Status: "
flow scripts execute ./scripts/is_creator.cdc $3

echo "---------- Answering Creators ----------"
flow transactions send ./transactions/answer/answer_creator_invite.cdc $2 --signer $1

echo -n "Verify Creator Status: "
flow scripts execute ./scripts/is_creator.cdc $3
