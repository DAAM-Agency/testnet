// get_all_metadpata.cdc
// Used to get a all Metadatas by all Creators

import DAAM_V4from 0xa4ad5ea5c0bd2fba

pub fun main(): {Address: {UInt64: DAAM.Metadata} }
{
    let creators = DAAM.getCreators()
    var metalist: {Address: {UInt64: DAAM.Metadata} } = {}        
    
    for creator in creators {
        let metadataRef = getAccount(creator)
            .getCapability<&DAAM.MetadataGenerator{DAAM.MetadataGeneratorPublic}>(DAAM.metadataPublicPath)
            .borrow() ?? panic("Could not borrow capability from Metadata")

        let metadatas = metadataRef.getMetadatas()        
        metalist.insert(key: creator, metadatas)    
    }

    return metalist
}
