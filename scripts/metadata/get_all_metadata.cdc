// get_all_metadpata.cdc
// Used to get all Metadatas by all Creators

import DAAM from 0xfd43f9148d4b725d

pub fun main(): {Address: [[DAAM.Metadata]; 2] }
{
    let creators = DAAM.getCreators()
    var mlist: [DAAM.Metadata] = []
    var clist: { Address : [[DAAM.Metadata]; 2] } = {}

    var metadataRef = getAccount(creators[0])
        .getCapability<&DAAM.MetadataGenerator{DAAM.MetadataGeneratorPublic}>(DAAM.metadataPublicPath)
        .borrow() ?? panic("Could not borrow capability from Metadata")

    let metadatas = metadataRef.getMetadatas()  
    for creator in creators {
        metadataRef = getAccount(creator)
            .getCapability<&DAAM.MetadataGenerator{DAAM.MetadataGeneratorPublic}>(DAAM.metadataPublicPath)
            .borrow() ?? panic("Could not borrow capability from Metadata")
        for m in metadatas.keys {
            mlist.append(metadatas[m]!)
        }
        let convert_metadata = DAAM.convertMetadata(metadata: mlist)
        clist.insert(key: creator, convert_metadata)
    }
    return clist
}
