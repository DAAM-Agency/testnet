// get_all_metadpata.cdc
// Used to get a all Metadatas by all Creators

import DAAM_V6 from 0xa4ad5ea5c0bd2fba

pub fun main(): {Address: {UInt64: DAAM_V6.Metadata} }
{
    let creators = DAAM_V6.getCreators()
    var metalist: {Address: {UInt64: DAAM_V6.Metadata} } = {}        
    
    for creator in creators {
        let metadataRef = getAccount(creator)
            .getCapability<&DAAM_V6.MetadataGenerator{DAAM_V6.MetadataGeneratorPublic}>(DAAM_V6.metadataPublicPath)
            .borrow() ?? panic("Could not borrow capability from Metadata")

        let metadatas = metadataRef.getMetadatas()        
        metalist.insert(key: creator, metadatas)    
    }

    return metalist
}
