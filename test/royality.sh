# Request Royality [MID, Percentage*] * 10-30%
# Fail: verify min/max
echo "========== Select Royality Rate =========="

echo "FAIL TEST: too low"
flow transactions send ./transactions/request/accept_default.cdc 2 0.09  --signer creator #B

echo "FAIL TEST: too high"
flow transactions send ./transactions/request/accept_default.cdc 2 0.31 --signer creator #B

echo "---------- Accept Defaults 10 & 20 ----------"
flow transactions send ./transactions/request/accept_default.cdc 1 0.10 --signer creator #A
flow transactions send ./transactions/request/accept_default.cdc 2 0.20 --signer creator #B

echo "FAIL TEST: #C does not exist. Removed Metadata by Creator"
flow transactions send ./transactions/request/accept_default.cdc 3 0.12 --signer creator #C

flow transactions send ./transactions/request/accept_default.cdc 4 0.18 --signer creator #D
flow transactions send ./transactions/request/accept_default.cdc 5 0.20 --signer creator #E
flow transactions send ./transactions/request/accept_default.cdc 6 0.25 --signer creator #F
flow transactions send ./transactions/request/accept_default.cdc 7 0.30 --signer creator #G
flow transactions send ./transactions/request/accept_default.cdc 8 0.15 --signer creator #H
flow transactions send ./transactions/request/accept_default.cdc 9 0.16 --signer creator #I

# Change Copyright [MID, Status*] *0=Fraud, 1=Claim, 2=Unverified, 3=Verfied
echo "========== Change Copyright Status =========="
flow transactions send ./transactions/admin/change_copyright.cdc 1 3 --signer admin #A Verfied
flow transactions send ./transactions/admin/change_copyright.cdc 2 3 --signer admin #B Verfied

echo "FAIL TEST: #C does not exist. Removed Metadata by Creator"
flow transactions send ./transactions/admin/change_copyright.cdc 3 3 --signer admin #C Verfied

echo "Note: Disapproved by Admin, but Copyright can still be modified."
flow transactions send ./transactions/admin/change_copyright.cdc 4 3 --signer admin #D Verfied

flow transactions send ./transactions/admin/change_copyright.cdc 5 1 --signer admin #E Claim

flow transactions send ./transactions/admin/change_copyright.cdc 6 3 --signer admin #F Verfied
flow transactions send ./transactions/admin/change_copyright.cdc 7 3 --signer admin #G Verfied
flow transactions send ./transactions/admin/change_copyright.cdc 8 3 --signer admin #H Verfied
flow transactions send ./transactions/admin/change_copyright.cdc 9 3 --signer admin #I Verfied

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
