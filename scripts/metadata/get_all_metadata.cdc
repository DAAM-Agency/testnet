// get_all_metadpata.cdc
// Used to get all Metadatas by all Creators

import DAAM_V7 from 0xa4ad5ea5c0bd2fba

pub fun main(): {Address: [[DAAM_V7.Metadata]; 2] }
{
    let creators = DAAM_V7.getCreators()
    var mlist: [DAAM_V7.Metadata] = []
    var clist: { Address : [[DAAM_V7.Metadata]; 2] } = {}

    var metadataRef = getAccount(creators[0])
        .getCapability<&DAAM_V7.MetadataGenerator{DAAM_V7.MetadataGeneratorPublic}>(DAAM_V7.metadataPublicPath)
        .borrow() ?? panic("Could not borrow capability from Metadata")

    let metadatas = metadataRef.getMetadatas()  
    for creator in creators {
        metadataRef = getAccount(creator)
            .getCapability<&DAAM_V7.MetadataGenerator{DAAM_V7.MetadataGeneratorPublic}>(DAAM_V7.metadataPublicPath)
            .borrow() ?? panic("Could not borrow capability from Metadata")
        for m in metadatas.keys {
            mlist.append(metadatas[m]!)
        }
        let convert_metadata = DAAM_V7.convertMetadata(metadata: mlist)
        clist.insert(key: creator, convert_metadata)
    }
    return clist
}
