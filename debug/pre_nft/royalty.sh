# Request Royalty [MID, Percentage*] * 10-30%
# Fail: verify min/max
echo "========== Select Royalty Rate =========="

echo "FAIL TEST: too low"
flow transactions send ./transactions/request/accept_default.cdc 2 0.09  --signer creator #B

echo "FAIL TEST: too high"
flow transactions send ./transactions/request/accept_default.cdc 2 0.31 --signer creator #B

echo "---------- Accept Defaults 10 & 20 ----------"
flow transactions send ./transactions/request/accept_default.cdc 1 0.10 --signer creator #A
flow transactions send ./transactions/request/accept_default.cdc 2 0.20 --signer creator #B

echo "FAIL TEST: #C does not exist. Removed Metadata by Creator"
flow transactions send ./transactions/request/accept_default.cdc 3 0.12 --signer creator #C

flow transactions send ./transactions/request/accept_default.cdc 4 0.18 --signer creator  #D
flow transactions send ./transactions/request/accept_default.cdc 5 0.20 --signer creator  #E
flow transactions send ./transactions/request/accept_default.cdc 6 0.25 --signer creator2 #F
flow transactions send ./transactions/request/accept_default.cdc 7 0.30 --signer creator2 #G
flow transactions send ./transactions/request/accept_default.cdc 8 0.15 --signer creator2 #H
flow transactions send ./transactions/request/accept_default.cdc 9 0.16 --signer creator2 #I