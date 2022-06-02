# Submit Metadatas: [Series Max Prints*, About/Misc Data, Thumbnail data, File Data] *0=Unlimited
# Tests: #A 1-Shot, #B Series(of 7), #C to be deleted by Creator. #D Disapproved by Admin, #E False Copyright,
#F Unlimited Print, #G 10 series
echo "========= Submit NFTs ========="
flow transactions send ./transactions/creator/submit_all.cdc "Name A" 2 '["Digital","Image"]' nil "description A" "String" "thumbnail A" "String" "file A" "String" 0.10 --signer creator # Will be MID 1
flow transactions send ./transactions/creator/submit_all.cdc "Name B" 7 '["Digital","Image"]' nil "description B" "String" "thumbnail B" "String" "file B" "String" 0.12 --signer creator # Will be MID 2
flow transactions send ./transactions/creator/submit_all.cdc "Name C" 2 '["Digital","Image"]' nil "description C" "String" "thumbnail C" "String" "file C" "String" 0.13 --signer creator # Will be MID 3
flow transactions send ./transactions/creator/submit_all.cdc "Name D" 0 '["Digital","Image"]' nil "description D" "String" "thumbnail D" "String" "file D" "String" 0.14 --signer creator # Will be MID 4
flow transactions send ./transactions/creator/submit_all.cdc "Name E" 3 '["Digital","Image"]' nil "description E" "String" "thumbnail E" "String" "file E" "String" 0.15 --signer creator # Will be MID 5
flow transactions send ./transactions/creator/submit_all.cdc "Name F" 2 '["Digital","Image"]' nil "description F" "String" "thumbnail F" "String" "file F" "String" 0.16 --signer creator2 # Will be MID 6
flow transactions send ./transactions/creator/submit_all.cdc "Name G" 2 '["Digital","Image"]' nil "description G" "String" "thumbnail G" "String" "file G" "String" 0.17 --signer creator2 # Will be MID 7
flow transactions send ./transactions/creator/submit_all.cdc "Name H" 4 '["Digital","Image"]' nil "description H" "String" "thumbnail H" "String" "file H" "String" 0.18 --signer creator2 # Will be MID 8
flow transactions send ./transactions/creator/submit_all.cdc "Name I" 2 '["Digital","Image"]' nil "description I" "String" "thumbnail I" "String" "file I" "String" 0.19 --signer creator2 # Will be MID 9

# Verify Metadata
echo "========= Verify Metadata ========="
for user in $CREATOR $CREATOR2
do
    METADATA=$(flow -o json scripts execute ./scripts/get_mids.cdc $user | jq ' .value' | grep value | awk '{print $2}' | tr -d '"')
    #echo "Metadata: "$METADATA
    for list in $METADATA
    do
        flow scripts execute ./scripts/view_metadata.cdc $user $list
    done
done