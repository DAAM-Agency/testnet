echo "Testing Section A ===================="
echo "Setup Accounts & Wallets"

# Setup Profiles
echo "========= Setup Profiles ========="
flow transactions send ./transactions/create_profile.cdc --signer admin2
flow transactions send ./transactions/create_profile.cdc --signer creator
flow transactions send ./transactions/create_profile.cdc --signer client
flow transactions send ./transactions/create_profile.cdc --signer nobody

# Setup DAAM Accounts
echo "========= Setup DAAM Accounts ========="
flow transactions send ./transactions/setup_daam_account.cdc --signer nobody
flow transactions send ./transactions/setup_daam_account.cdc --signer creator
flow transactions send ./transactions/setup_daam_account.cdc --signer client
flow transactions send ./transactions/setup_daam_account.cdc --signer admin2

# Setup Auction Wallets
echo "========= Setup Auction Wallets ========="
flow transactions send ./transactions/auction/create_auction_wallet.cdc --signer nobody
flow transactions send ./transactions/auction/create_auction_wallet.cdc --signer creator
flow transactions send ./transactions/auction/create_auction_wallet.cdc --signer client
flow transactions send ./transactions/auction/create_auction_wallet.cdc --signer admin2

# ACCOUNTS SETUP END --------------------------- 

# Invite Creator & Accept
echo "========= Invite Creator ========="
# accept
flow transactions send ./transactions/admin/invite_creator.cdc $CREATOR --signer admin
flow transactions send ./transactions/answer_creator_invite.cdc true --signer creator
# decline
flow transactions send ./transactions/admin/invite_creator.cdc $ADMIN2 --signer admin
flow transactions send ./transactions/answer_creator_invite.cdc false --signer admin2

# Invite Admin #2
echo "========= Invite Admin ========="
# decline
flow transactions send ./transactions/admin/invite_admin.cdc $ADMIN2 --signer admin
flow transactions send ./transactions/answer_admin_invite.cdc false --signer admin2
#accept
flow transactions send ./transactions/admin/invite_admin.cdc $ADMIN2 --signer admin
flow transactions send ./transactions/answer_admin_invite.cdc true --signer admin2

# Remove Admin / Creator
echo "========= Remove Admin & Creator ========="
# admin
echo "---------- Get 1 of 2 Admin Votes ----------"
flow transactions send ./transactions/admin/remove_admin.cdc $ADMIN2 --signer admin

echo "FAIL TEST: Removing Admin: Not Admin"
flow transactions send ./transactions/admin/remove_admin.cdc $ADMIN2 --signer client

echo "---------- Get 2 of 2 Admin Votes ----------"
flow transactions send ./transactions/admin/remove_admin.cdc $ADMIN2 --signer admin2

# creator
echo "FAIL TEST: Removing Creator: Not Admin"
flow transactions send ./transactions/admin/remove_creator.cdc $CREATOR --signer client

echo "---------- Remove Creator ----------"
flow transactions send ./transactions/admin/remove_creator.cdc $CREATOR --signer admin

# Delete / Reset Addresses
flow transactions send ./transactions/creator/delete_creator.cdc --signer creator
flow transactions send ./transactions/admin/delete_admin.cdc --signer admin2

# (Re)Invite Creator & Accept
echo "========= Re(Invite) Admin & Creator ========="

echo "---------- Invite Creator ----------"
flow transactions send ./transactions/admin/invite_creator.cdc $CREATOR --signer admin
echo "----------- Decline Invitation ----------"
flow transactions send ./transactions/answer_creator_invite.cdc false --signer creator

echo "----------- Invite: Creator -----------"
flow transactions send ./transactions/admin/invite_creator.cdc $CREATOR --signer admin
echo "----------- Accept Invitation ----------"
flow transactions send ./transactions/answer_creator_invite.cdc true --signer creator

# (Re)Invite Admin #2
echo "----------- Invite: Admin -----------"
flow transactions send ./transactions/admin/invite_admin.cdc $ADMIN2 --signer admin
echo "Decline Invite: Admin"
flow transactions send ./transactions/answer_admin_invite.cdc false --signer admin2

echo "----------- Invite: Admin -----------"
flow transactions send ./transactions/admin/invite_admin.cdc $ADMIN2 --signer admin
echo "Accept Invite: Admin"
flow transactions send ./transactions/answer_admin_invite.cdc true --signer admin2

echo "Testing Section B ===================="
echo "Setup NFTs"

# Submit Metadatas: [Series Max Prints*, About/Misc Data, Thumbnail data, File Data] *0=Unlimited
# Tests: #A 1-Shot, #B Series(of 7), #C to be deleted by Creator. #D Disapproved by Admin, #E False Copyright,
#F Unlimited Print, #G 10 series
echo "========= Submite NFTs ========="
flow transactions send ./transactions/creator/submit_nft.cdc 2 "data A" "thumbnail A" "file A" --signer creator
flow transactions send ./transactions/creator/submit_nft.cdc 7 "data B" "thumbnail B" "file B" --signer creator
flow transactions send ./transactions/creator/submit_nft.cdc 2 "data C" "thumbnail C" "file C" --signer creator
flow transactions send ./transactions/creator/submit_nft.cdc 0 "data D" "thumbnail D" "file D" --signer creator
flow transactions send ./transactions/creator/submit_nft.cdc 3 "data E" "thumbnail E" "file E" --signer creator
flow transactions send ./transactions/creator/submit_nft.cdc 4 "data F" "thumbnail F" "file F" --signer creator
flow transactions send ./transactions/creator/submit_nft.cdc 2 "data G" "thumbnail G" "file G" --signer creator
flow transactions send ./transactions/creator/submit_nft.cdc 4 "data H" "thumbnail H" "file H" --signer creator
flow transactions send ./transactions/creator/submit_nft.cdc 2 "data I" "thumbnail I" "file I" --signer creator

echo "========= Veriy Metadata ========="
# verify metadata
flow scripts execute ./scripts/metadata/get_metadata_list.cdc $CREATOR

# Remove Metadata [MID]
echo "========= Remove Metadata Submission ========="
flow transactions send ./transactions/creator/remove_submission.cdc 3 --signer creator  #C MID 3 

# Verify Metadata
echo "========= Veriy Metadata ========="
flow scripts execute ./scripts/metadata/get_metadata_list.cdc $CREATOR #C No longer exist

# Dis/Approve the Metadatas [MID, Status]
echo "========= Approve Metadata Submissions ========="
flow transactions send ./transactions/admin/change_metadata_status.cdc 1 true --signer admin   # MID 1
flow transactions send ./transactions/admin/change_metadata_status.cdc 2 true --signer admin2  # MID 2

echo "FAIL TEST: Metadata removed by Creator"
flow transactions send ./transactions/admin/change_metadata_status.cdc 3 true --signer admin2  # MID 3 #C No longer exist
echo "---------- Disapprove Metadata by Admin----------"
flow transactions send ./transactions/admin/change_metadata_status.cdc 4 false --signer admin2 #D Disapproved by Admin, No longer exist

flow transactions send ./transactions/admin/change_metadata_status.cdc 5 true --signer admin2  # MID 5
flow transactions send ./transactions/admin/change_metadata_status.cdc 6 true --signer admin2  # MID 6
flow transactions send ./transactions/admin/change_metadata_status.cdc 7 true --signer admin2  # MID 7
flow transactions send ./transactions/admin/change_metadata_status.cdc 8 true --signer admin2  # MID 7
flow transactions send ./transactions/admin/change_metadata_status.cdc 9 true --signer admin2  # MID 7

# Verify Metadata
echo "========= Veriy Metadata ========="
flow scripts execute ./scripts/metadata/get_metadata_list.cdc $CREATOR

# Request Royality [MID, Percentage*] * 10-30%
# Fail: verify min/max
echo "========== Select Royality Rate =========="
echo "FAIL TEST: too low"
flow transactions send ./transactions/request/accept_default.cdc 2 0.99  --signer creator #B
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
flow transactions send ./transactions/request/accept_default.cdc 8 0.15 --signer creator #G
flow transactions send ./transactions/request/accept_default.cdc 9 0.16 --signer creator #G

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
