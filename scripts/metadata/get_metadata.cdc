// get_metadata.cdc
// Used to get a specific Metadata using the Creator and MID

import DAAM_V7 from 0xa4ad5ea5c0bd2fba

pub fun main(creator: Address, mid: UInt64): [[DAAM_V7.Metadata];2]
{
    let metadataGenRef = getAccount(creator)
        .getCapability<&DAAM_V7.MetadataGenerator{DAAM_V7.MetadataGeneratorPublic}>(DAAM_V7.metadataPublicPath)
        .borrow() ?? panic("Could not borrow capability from Metadata")
    let metadataRef = metadataGenRef.getMetadataRef(mid: mid)
    let metadata = metadataGenRef.getMetadatas()[mid]!
    let convert_metadata = DAAM_V7.convertMetadata(metadata: [metadata])
    
    return convert_metadata
}


