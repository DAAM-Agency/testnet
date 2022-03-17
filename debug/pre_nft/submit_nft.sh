# Submit Metadatas: [Series Max Prints*, About/Misc Data, Thumbnail data, File Data] *0=Unlimited
# Tests: #A 1-Shot, #B Series(of 7), #C to be deleted by Creator. #D Disapproved by Admin, #E False Copyright,
#F Unlimited Print, #G 10 series
echo "========= Submit NFTs ========="
flow transactions send ./transactions/creator/submit_all.cdc 2 '["Digital","Image"]' "data A" "thumbnail A" "file A" 0.15 --signer creator # Will be MID 1
flow transactions send ./transactions/creator/submit_all.cdc 7 '["Digital","Image"]' "data B" "thumbnail B" "file B" 0.15 --signer creator # Will be MID 2
flow transactions send ./transactions/creator/submit_all.cdc 2 '["Digital","Image"]' "data C" "thumbnail C" "file C" 0.15 --signer creator # Will be MID 3
flow transactions send ./transactions/creator/submit_all.cdc 0 '["Digital","Image"]' "data D" "thumbnail D" "file D" 0.15 --signer creator # Will be MID 4
flow transactions send ./transactions/creator/submit_all.cdc 3 '["Digital","Image"]' "data E" "thumbnail E" "file E" 0.15 --signer creator # Will be MID 5
flow transactions send ./transactions/creator/submit_all.cdc 2 '["Digital","Image"]' "data F" "thumbnail F" "file F" 0.15 --signer creator2 # Will be MID 6
flow transactions send ./transactions/creator/submit_all.cdc 2 '["Digital","Image"]' "data G" "thumbnail G" "file G" 0.15 --signer creator2 # Will be MID 7
flow transactions send ./transactions/creator/submit_all.cdc 4 '["Digital","Image"]' "data H" "thumbnail H" "file H" 0.15 --signer creator2 # Will be MID 8
flow transactions send ./transactions/creator/submit_all.cdc 2 '["Digital","Image"]' "data I" "thumbnail I" "file I" 0.15 --signer creator2 # Will be MID 9

echo "========= Verify Metadata ========="
# verify metadata
flow scripts execute ./scripts/daam_wallet/get_tokenIDs.cdc $CREATOR 
flow scripts execute ./scripts/daam_wallet/get_tokenIDs.cdc $CREATOR2 
