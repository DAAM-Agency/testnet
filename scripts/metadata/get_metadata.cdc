// get_metadata.cdc

import DAAM_V2.V2 from 0xfd43f9148d4b725d

pub fun main(creator: Address, mid: UInt64): &DAAM_V2.Metadata
{
    let metadataRef = getAccount(creator)
        .getCapability<&DAAM_V2.MetadataGenerator>(DAAM_V2.metadataPublicPath)
        .borrow() ?? panic("Could not borrow capability from Metadata")

    return metadataRef.getMetadataRef(mid: mid)
}
