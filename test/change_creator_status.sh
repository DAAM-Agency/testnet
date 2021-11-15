# Change Creator Status
echo "========== Change Creator Status (to verify access) =========="
flow transactions send ./transactions/admin/change_creator_status.cdc $CREATOR false --signer admin2

# Fail: Creator is set to False
echo "FAIL TEST: Submit NFT will fail, Creator has no access."
flow transactions send ./transactions/creator/submit_nft.cdc 1 "data test_copyright" "thumbnail cp" "file cp" --signer creator

# set status back to true
echo "========== Change Creator Status (return to true) =========="
flow transactions send ./transactions/admin/change_creator_status.cdc $CREATOR true  --signer admin2

# Look at participents collections
echo "---------- View Collections ----------"
echo Creator
flow scripts execute ./scripts/collecion.cdc $CREATOR
echo Client
flow scripts execute ./scripts/collecion.cdc $CLIENT
echo Nobody
flow scripts execute ./scripts/collecion.cdc $NOBODY
