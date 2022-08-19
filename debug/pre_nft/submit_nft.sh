# Submit Metadatas: [Series Max Prints*, About/Misc Data, Thumbnail data, File Data] *0=Unlimited
# Tests: #A 1-Shot, #B Series(of 7), #C to be deleted by Creator. #D Disapproved by Admin, #E False Copyright,
#F Unlimited Print, #G 10 series
echo "========= Submit NFTs ========="
flow transactions send ./transactions/creator/submit_accept.cdc --args-json '[
    {"type": "String", "value": "Name A"},
    {"type": "UInt64", "value": "2"},
    {"type": "Array", "value": [{"type": "String", "value": "Digital"}, {"type": "String", "value": "Image"}]},
    {"type": "String", "value": "description A"},
    {"type": "String", "value": "misc A"},
    {"type": "Bool", "value": false},
    {"type": "String", "value": "thumbnail A"},
    {"type": "String", "value": "text"},
    {"type": "Bool", "value": false},
    {"type": "String", "value": "file A"},
    {"type": "String", "value": "text"},
    {"type": "Optional", "value": null},
    {"type": "UFix64", "value": "0.10"}
    ]' --signer creator # Will be MID 1

flow transactions send ./transactions/creator/submit_accept.cdc --args-json '[
    {"type": "String", "value": "Name B"},
    {"type": "UInt64", "value": "7"},
    {"type": "Array", "value": [{"type": "String", "value": "Digital"}, {"type": "String", "value": "Image"}]},
    {"type": "String", "value": "description B"},
    {"type": "String", "value": "misc B"},
    {"type": "Bool", "value": false},
    {"type": "String", "value": "thumbnail B"},
    {"type": "String", "value": "text"},
    {"type": "Bool", "value": false},
    {"type": "String", "value": "file B"},
    {"type": "String", "value": "text"},
    {"type": "Optional", "value": null},
    {"type": "UFix64", "value": "0.12"}
    ]' --signer creator # Will be MID 2

flow transactions send ./transactions/creator/submit_accept.cdc --args-json '[
    {"type": "String", "value": "Name C"},
    {"type": "UInt64", "value": "2"},
    {"type": "Array", "value": [{"type": "String", "value": "Digital"}, {"type": "String", "value": "Image"}]},
    {"type": "String", "value": "description C"},
    {"type": "String", "value": "misc C"},
    {"type": "Bool", "value": false},
    {"type": "String", "value": "thumbnail C"},
    {"type": "String", "value": "text"},
    {"type": "Bool", "value": false},
    {"type": "String", "value": "file C"},
    {"type": "String", "value": "text"},
    {"type": "Optional", "value": null},
    {"type": "UFix64", "value": "0.13"}
    ]' --signer creator # Will be MID 3

flow transactions send ./transactions/creator/submit_accept.cdc --args-json '[
    {"type": "String", "value": "Name D"},
    {"type": "Optional", "value": null},
    {"type": "Array", "value": [{"type": "String", "value": "Digital"}, {"type": "String", "value": "Image"}]},
    {"type": "String", "value": "description D"},
    {"type": "String", "value": "misc D"},
    {"type": "Bool", "value": false},
    {"type": "String", "value": "thumbnail D"},
    {"type": "String", "value": "text"},
    {"type": "Bool", "value": false},
    {"type": "String", "value": "file D"},
    {"type": "String", "value": "text"},
    {"type": "Optional", "value": null},
    {"type": "UFix64", "value": "0.14"}
    ]' --signer creator # Will be MID 4

flow transactions send ./transactions/creator/submit_accept.cdc --args-json '[
    {"type": "String", "value": "Name E"},
    {"type": "UInt64", "value": "3"},
    {"type": "Array", "value": [{"type": "String", "value": "Digital"}, {"type": "String", "value": "Image"}]},
    {"type": "String", "value": "description E"},
    {"type": "String", "value": "misc E"},
    {"type": "Bool", "value": false},
    {"type": "String", "value": "thumbnail E"},
    {"type": "String", "value": "text"},
    {"type": "Bool", "value": false},
    {"type": "String", "value": "file E"},
    {"type": "String", "value": "text"},
    {"type": "Optional", "value": null},
    {"type": "UFix64", "value": "0.15"}
    ]' --signer creator # Will be MID 5

flow transactions send ./transactions/creator/submit_accept.cdc --args-json '[
    {"type": "String", "value": "Name F"},
    {"type": "UInt64", "value": "2"},
    {"type": "Array", "value": [{"type": "String", "value": "Digital"}, {"type": "String", "value": "Image"}]},
    {"type": "String", "value": "description F"},
    {"type": "String", "value": "misc F"},
    {"type": "Bool", "value": false},
    {"type": "String", "value": "thumbnail F"},
    {"type": "String", "value": "text"},
    {"type": "Bool", "value": false},
    {"type": "String", "value": "file F"},
    {"type": "String", "value": "text"},
    {"type": "Optional", "value": null},
    {"type": "UFix64", "value": "0.16"}
    ]' --signer creator2 # Will be MID 6

flow transactions send ./transactions/creator/submit_accept.cdc --args-json '[
    {"type": "String", "value": "Name G"},
    {"type": "UInt64", "value": "2"},
    {"type": "Array", "value": [{"type": "String", "value": "Digital"}, {"type": "String", "value": "Image"}]},
    {"type": "String", "value": "description G"},
    {"type": "String", "value": "misc G"},
    {"type": "Bool", "value": false},
    {"type": "String", "value": "thumbnail G"},
    {"type": "String", "value": "text"},
    {"type": "Bool", "value": false},
    {"type": "String", "value": "file G"},
    {"type": "String", "value": "text"},
    {"type": "Optional", "value": null},
    {"type": "UFix64", "value": "0.17"}
    ]' --signer creator2 # Will be MID 7

flow transactions send ./transactions/creator/submit_accept.cdc --args-json '[
    {"type": "String", "value": "Name H"},
    {"type": "UInt64", "value": "4"},
    {"type": "Array", "value": [{"type": "String", "value": "Digital"}, {"type": "String", "value": "Image"}]},
    {"type": "String", "value": "description H"},
    {"type": "String", "value": "misc H"},
    {"type": "Bool", "value": false},
    {"type": "String", "value": "thumbnail H"},
    {"type": "String", "value": "text"},
    {"type": "Bool", "value": false},
    {"type": "String", "value": "file H"},
    {"type": "String", "value": "text"},
    {"type": "Optional", "value": null},
    {"type": "UFix64", "value": "0.18"}
    ]' --signer creator2 # Will be MID 8

flow transactions send ./transactions/creator/submit_accept.cdc --args-json '[
    {"type": "String", "value": "Name I"},
    {"type": "UInt64", "value": "2"},
    {"type": "Array", "value": [{"type": "String", "value": "Digital"}, {"type": "String", "value": "Image"}]},
    {"type": "String", "value": "description I"},
    {"type": "String", "value": "misc I"},
    {"type": "Bool", "value": false},
    {"type": "String", "value": "thumbnail I"},
    {"type": "String", "value": "text"},
    {"type": "Bool", "value": false},
    {"type": "String", "value": "file I"},
    {"type": "String", "value": "text"},
    {"type": "Optional", "value": null},
    {"type": "UFix64", "value": "0.19"}
    ]' --signer creator2 # Will be MID 9

flow transactions send ./transactions/creator/submit_accept.cdc --args-json '[
    {"type": "String", "value": "Name J"},
    {"type": "Optional", "value": null},
    {"type": "Array", "value": [{"type": "String", "value": "Digital"}, {"type": "String", "value": "Image"}]},
    {"type": "String", "value": "description J"},
    {"type": "String", "value": "misc J"},
    {"type": "Bool", "value": false},
    {"type": "String", "value": "thumbnail J"},
    {"type": "String", "value": "text"},
    {"type": "Bool", "value": false},
    {"type": "String", "value": "file J"},
    {"type": "String", "value": "text"},
    {"type": "Optional", "value": null},
    {"type": "UFix64", "value": "0.20"}
    ]' --signer creator2 # Will be MID 10


# Verify Metadata
echo "========= Verify Metadata ========="
for user in $CREATOR $CREATOR2
do
    flow -o json scripts execute ./scripts/get_mids.cdc $user | jq ' .value' 
done