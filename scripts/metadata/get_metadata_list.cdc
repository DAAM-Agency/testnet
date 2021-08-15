// get_metadata_list.cdc

import DAAM_V3.V2 from 0xfd43f9148d4b725d

pub fun main(creator: Address): &{UInt64 : DAAM_V3.Metadata}
{
    let metadataRef = getAccount(creator)
        .getCapability<&DAAM_V3.MetadataGenerator>(DAAM_V3.metadataPublicPath)
        .borrow() ?? panic("Could not borrow capability from Metadata")

    return metadataRef.getMetadata()
}
