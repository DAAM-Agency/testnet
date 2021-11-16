# Change Creator Status
echo "========== Change Creator Status =========="
ech0 "---------- Change Creator Status: false"
flow transactions send ./transactions/admin/change_creator_status.cdc $CREATOR false --signer cto

# Fail: Creator is set to False
echo "FAIL TEST: Submit NFT will fail, Creator has no access."
flow transactions send ./transactions/creator/submit_nft.cdc 1 "data test_copyright" "thumbnail cp" "file cp" --signer creator

# set status back to true
ech0 "---------- Change Creator Status: true"
flow transactions send ./transactions/admin/change_creator_status.cdc $CREATOR true  --signer cto

echo "FAIL TEST: Verify Access: Incorrect Access"
flow transactions send ./transactions/admin/change_creator_status.cdc $CREATOR false --signer creator
