# Submit Metadatas: [Series Max Prints*, About/Misc Data, Thumbnail data, File Data] *0=Unlimited
# Tests: #A 1-Shot, #B Series(of 7), #C to be deleted by Creator. #D Disapproved by Admin, #E False Copyright,
#F Unlimited Print, #G 10 series
echo "========= Submit NFTs ========="
flow transactions send ./transactions/creator/submit_accept.cdc "Name A" 2 '["Digital","Image"]' nil "description A" false  "thumbnail A" "file" false  "file A" "file" nil 0.10 --signer creator # Will be MID 1
flow transactions send ./transactions/creator/submit_accept.cdc "Name B" 7 '["Digital","Image"]' nil "description B" false  "thumbnail B" "file" false  "file B" "file" nil 0.12 --signer creator # Will be MID 2
flow transactions send ./transactions/creator/submit_accept.cdc "Name C" 2 '["Digital","Image"]' nil "description C" false  "thumbnail C" "file" false  "file C" "file" nil 0.13 --signer creator # Will be MID 3
flow transactions send ./transactions/creator/submit_accept.cdc "Name D" nil '["Digital","Image"]' nil "description D" false  "thumbnail D" "file" false  "file D" "file" nil 0.14 --signer creator # Will be MID 4
flow transactions send ./transactions/creator/submit_accept.cdc "Name E" 3 '["Digital","Image"]' nil "description E" false  "thumbnail E" "file" false  "file E" "file" nil 0.15 --signer creator # Will be MID 5
flow transactions send ./transactions/creator/submit_accept.cdc "Name F" 2 '["Digital","Image"]' nil "description F" false  "thumbnail F" "file" false  "file F" "file" nil 0.16 --signer creator2 # Will be MID 6
flow transactions send ./transactions/creator/submit_accept.cdc "Name G" 2 '["Digital","Image"]' nil "description G" false  "thumbnail G" "file" false  "file G" "file" nil 0.17 --signer creator2 # Will be MID 7
flow transactions send ./transactions/creator/submit_accept.cdc "Name H" 4 '["Digital","Image"]' nil "description H" false  "thumbnail H" "file" false  "file H" "file" nil 0.18 --signer creator2 # Will be MID 8
flow transactions send ./transactions/creator/submit_accept.cdc "Name I" 2 '["Digital","Image"]' nil "description I" false  "thumbnail I" "file" false  "file I" "file" nil 0.19 --signer creator2 # Will be MID 9
flow transactions send ./transactions/creator/submit_accept.cdc "Name J" nil '["Digital","Image"]' nil "description J" false  "thumbnail J" "file" false  "file J" "file" nil 0.20 --signer creator2 # Will be MID 10

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