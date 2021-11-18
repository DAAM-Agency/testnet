# Submit Metadatas: [Series Max Prints*, About/Misc Data, Thumbnail data, File Data] *0=Unlimited
# Tests: #A 1-Shot, #B Series(of 7), #C to be deleted by Creator. #D Disapproved by Admin, #E False Copyright,
#F Unlimited Print, #G 10 series
echo "========= Submit NFTs ========="
flow transactions send ./transactions/creator/submit_nft.cdc 2 "data A" "thumbnail A" "file A" --signer creator
flow transactions send ./transactions/creator/submit_nft.cdc 7 "data B" "thumbnail B" "file B" --signer creator
flow transactions send ./transactions/creator/submit_nft.cdc 2 "data C" "thumbnail C" "file C" --signer creator
flow transactions send ./transactions/creator/submit_nft.cdc 0 "data D" "thumbnail D" "file D" --signer creator
flow transactions send ./transactions/creator/submit_nft.cdc 3 "data E" "thumbnail E" "file E" --signer creator
flow transactions send ./transactions/creator/submit_nft.cdc 2 "data F" "thumbnail F" "file F" --signer creator2
flow transactions send ./transactions/creator/submit_nft.cdc 2 "data G" "thumbnail G" "file G" --signer creator2
flow transactions send ./transactions/creator/submit_nft.cdc 4 "data H" "thumbnail H" "file H" --signer creator2
flow transactions send ./transactions/creator/submit_nft.cdc 2 "data I" "thumbnail I" "file I" --signer creator2

echo "========= Veriy Metadata ========="
# verify metadata
flow scripts execute ./scripts/metadata/get_metadata_list.cdc $CREATOR 
flow scripts execute ./scripts/metadata/get_metadata_list.cdc $CREATOR2 
