// get_all_metadpata.cdc
// Used to get a all Metadatas by all Creators

<<<<<<< HEAD
import DAAM_V5from 0xa4ad5ea5c0bd2fba
=======
import DAAM_V5 from 0xa4ad5ea5c0bd2fba
>>>>>>> merge_dev

pub fun main(): {Address: {UInt64: DAAM_V5.Metadata} }
{
    let creators = DAAM_V5.getCreators()
    var metalist: {Address: {UInt64: DAAM_V5.Metadata} } = {}        
    
    for creator in creators {
        let metadataRef = getAccount(creator)
            .getCapability<&DAAM_V5.MetadataGenerator{DAAM_V5.MetadataGeneratorPublic}>(DAAM_V5.metadataPublicPath)
            .borrow() ?? panic("Could not borrow capability from Metadata")

        let metadatas = metadataRef.getMetadatas()        
        metalist.insert(key: creator, metadatas)    
    }

    return metalist
}
