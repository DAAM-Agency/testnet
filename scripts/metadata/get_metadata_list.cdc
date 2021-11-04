// get_metadata_list.cdc

import DAAM from 0xfd43f9148d4b725d

pub fun main(creator: Address): &{UInt64 : DAAM.Metadata}
{
    let metadataRef = getAccount(creator)
        .getCapability<&DAAM.MetadataGenerator>(DAAM.metadataPublicPath)
        .borrow() ?? panic("Could not borrow capability from Metadata")

    return metadataRef.getMetadata()
}
