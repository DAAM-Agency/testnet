// get_metadata.cdc
// Used to get a specific Metadata using the Creator and MID

import DAAM_V4 from 0xa4ad5ea5c0bd2fba

pub fun main(creator: Address, mid: UInt64): &DAAM_V4.Metadata
{
    let metadataRef = getAccount(creator)
        .getCapability<&DAAM_V4.MetadataGenerator{DAAM_V4.MetadataGeneratorPublic}>(DAAM_V4.metadataPublicPath)
        .borrow() ?? panic("Could not borrow capability from Metadata")

    return metadataRef.getMetadataRef(mid: mid)
}
