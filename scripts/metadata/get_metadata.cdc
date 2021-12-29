// get_metadata.cdc
// Used to get a specific Metadata using the Creator and MID

import DAAM from 0xfd43f9148d4b725d

pub fun main(creator: Address, mid: UInt64): [[DAAM.Metadata];2]
{
    let metadataGenRef = getAccount(creator)
        .getCapability<&DAAM.MetadataGenerator{DAAM.MetadataGeneratorPublic}>(DAAM.metadataPrivatePath)
        .borrow() ?? panic("Could not borrow capability from Metadata")
    let metadataRef = metadataGenRef.getMetadataRef(mid: mid)
    let metadata = metadataGenRef.getMetadatas()[mid]!
    let convert_metadata = DAAM.convertMetadata(metadata: [metadata])
    
    return convert_metadata
}


