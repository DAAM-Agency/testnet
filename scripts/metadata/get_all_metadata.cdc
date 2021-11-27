// get_all_metadpata.cdc
// Used to get all Metadatas by all Creators

import DAAM_V6 from 0xa4ad5ea5c0bd2fba

pub fun main(): {Address: [[DAAM_V6.Metadata]; 2] }
{
    let creators = DAAM_V6.getCreators()
    var mlist: [DAAM_V6.Metadata] = []
    var clist: { Address : [[DAAM_V6.Metadata]; 2] } = {}
    
    for creator in creators {
        let metadataRef = getAccount(creator)
            .getCapability<&DAAM_V6.MetadataGenerator{DAAM_V6.MetadataGeneratorPublic}>(DAAM_V6.metadataPublicPath)
            .borrow() ?? panic("Could not borrow capability from Metadata")

        let metadatas = metadataRef.getMetadatas()        
        for m in metadatas.keys {
            mlist.append(metadatas[m]!)
        }
        let convert_metadata = DAAM_V6.convertMetadata(metadata: mlist)
        clist.insert(key: creator, convert_metadata)
    }
    return clist
}
