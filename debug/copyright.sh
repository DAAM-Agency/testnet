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
