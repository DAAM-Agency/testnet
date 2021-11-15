# Invite Admin & Accept
echo "========= Invite Admins, Agents, & Creator ========="

echo "---------- Inviting Admins ----------"
for user in $ADMIN $ADMIN2
do
getAddressName $user
flow transactions send ./transactions/admin/invite_admin.cdc $user --signer cto
done

echo "---------- Inviting Agents ----------"
for user in $AGENT $AGENT2
do
getAddressName $user
flow transactions send ./transactions/admin/invite_agent.cdc $user --signer admin
done

echo "---------- Inviting Creators ----------"
for user in $CREATOR $CREATOR2
do
getAddressName $user
flow transactions send ./transactions/admin/invite_creator.cdc $user --signer admin2
done


flow transactions send ./transactions/admin/invite_creator.cdc $CREATOR --signer admin
flow transactions send ./transactions/answer_creator_invite.cdc true --signer creator
# decline
flow transactions send ./transactions/admin/invite_admin.cdc $ADMIN2 --signer admin
flow transactions send ./transactions/answer_admin_invite.cdc false --signer admin2

# Invite Admin #2
echo "========= Invite Admin ========="
# decline
flow transactions send ./transactions/admin/invite_admin.cdc $ADMIN2 --signer admin
flow transactions send ./transactions/answer_admin_invite.cdc false --signer admin2
#accept
flow transactions send ./transactions/admin/invite_admin.cdc $ADMIN2 --signer admin
flow transactions send ./transactions/answer_admin_invite.cdc true --signer admin2

# Remove Admin & Creator
# Admin
echo "========= Remove Admin & Creator ========="

echo "========== Verify Admin Status: Admin2 (True) =========="
flow scripts execute ./scripts/is_admin.cdc $ADMIN2

echo "---------- Get 1 of 2 Admin Votes ----------"
flow transactions send ./transactions/admin/remove_admin.cdc $ADMIN2 --signer admin

echo "FAIL TEST: Removing Admin: Not Admin"
flow transactions send ./transactions/admin/remove_admin.cdc $ADMIN2 --signer client

echo "---------- Get 2 of 2 Admin Votes ----------"
flow transactions send ./transactions/admin/remove_admin.cdc $ADMIN2 --signer admin2

echo "========== Verify Admin Status: Admin2 (False) =========="
flow scripts execute ./scripts/is_admin.cdc $ADMIN2

# creator
echo "FAIL TEST: Attempting to Remove Creator by non-Admin"
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