// get_metadata.cdc
// Used to get a specific Metadata using the Creator and MID

import DAAM_V6 from 0xa4ad5ea5c0bd2fba

pub fun main(creator: Address, mid: UInt64): [[DAAM_V6.Metadata];2]
{
    let metadataGenRef = getAccount(creator)
        .getCapability<&DAAM_V6.MetadataGenerator{DAAM_V6.MetadataGeneratorPublic}>(DAAM_V6.metadataPublicPath)
        .borrow() ?? panic("Could not borrow capability from Metadata")

    let metadata = metadataGenRef.getMetadataRef(mid: mid)
    let convert_metadata = DAAM_V6.convertMetadata(metadata: [metadata])

    return convert_metadata
}


