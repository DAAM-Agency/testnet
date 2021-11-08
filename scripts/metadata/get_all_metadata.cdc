// get_all_metadpata.cdc
// Used to get a all Metadatas by all Creators

import DAAM from 0xfd43f9148d4b725d

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
