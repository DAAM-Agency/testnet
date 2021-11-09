// get_metadata_list.cdc
// Used to get a all Metadatas from a Creator

import DAAM_V5 from 0xa4ad5ea5c0bd2fba

pub fun main(creator: Address): {UInt64 : DAAM_V5.Metadata}
{
    let metadataRef = getAccount(creator)
        .getCapability<&DAAM_V5.MetadataGenerator{DAAM_V5.MetadataGeneratorPublic}>(DAAM_V5.metadataPublicPath)
        .borrow() ?? panic("Could not borrow capability from Metadata")

    return metadataRef.getMetadatas()
}
