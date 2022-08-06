# Submit Metadatas: [Series Max Prints*, About/Misc Data, Thumbnail data, File Data] *0=Unlimited
# Tests: #A 1-Shot, #B Series(of 7), #C to be deleted by Creator. #D Disapproved by Admin, #E False Copyright,
#F Unlimited Print, #G 10 series
echo "========= Submit NFTs ========="
flow transactions send ./transactions/creator/submit_accept.cdc "Name A" 2 true  '["Digital","Image"]' nil "description A" "misc A" false "thumbnail A" "text" false  "file A" "text" nil 0.10 --signer creator # Will be MID 1
flow transactions send ./transactions/creator/submit_accept.cdc "Name B" 7 false '["Digital","Image"]' nil "description B" "misc B" false "thumbnail B" "text" false  "file B" "text" nil 0.12 --signer creator # Will be MID 2
flow transactions send ./transactions/creator/submit_accept.cdc "Name C" 2 true  '["Digital","Image"]' nil "description C" "misc C" false "thumbnail C" "text" false  "file C" "text" nil 0.13 --signer creator # Will be MID 3
flow transactions send ./transactions/creator/submit_accept.cdc "Name D" nil false '["Digital","Image"]' nil "description D" "misc D" false "thumbnail D" "text" false  "file D" "text" nil 0.14 --signer creator # Will be MID 4
flow transactions send ./transactions/creator/submit_accept.cdc "Name E" 3 false '["Digital","Image"]' nil "description E" "misc E" false "thumbnail E" "text" false  "file E" "text" nil 0.15 --signer creator # Will be MID 5
flow transactions send ./transactions/creator/submit_accept.cdc "Name F" 2 false '["Digital","Image"]' nil "description F" "misc f" false "thumbnail F" "text" false  "file F" "text" nil 0.16 --signer creator2 # Will be MID 6
flow transactions send ./transactions/creator/submit_accept.cdc "Name G" 2 false '["Digital","Image"]' nil "description G" "misc G" false "thumbnail G" "text" false  "file G" "text" nil 0.17 --signer creator2 # Will be MID 7
flow transactions send ./transactions/creator/submit_accept.cdc "Name H" 4 false '["Digital","Image"]' nil "description H" "misc h" false "thumbnail H" "text" false  "file H" "text" nil 0.18 --signer creator2 # Will be MID 8
flow transactions send ./transactions/creator/submit_accept.cdc "Name I" 2 true '["Digital","Image"]' nil "description I" "misc I" false  "thumbnail I" "text" false  "file I" "text" nil 0.19 --signer creator2 # Will be MID 9
flow transactions send ./transactions/creator/submit_accept.cdc "Name J" nil false '["Digital","Image"]' nil "description J" "misc j" false "thumbnail J" "text" false  "file J" "text" nil 0.20 --signer creator2 # Will be MID 10

# Verify Metadata
echo "========= Verify Metadata ========="
for user in $CREATOR $CREATOR2
do
    flow -o json scripts execute ./scripts/get_mids.cdc $user | jq ' .value' 
done