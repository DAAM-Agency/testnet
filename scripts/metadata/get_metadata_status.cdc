// get_metadata_status.cdc
// Used to get Metadata status. Which are approved or disapproved.

import DAAM from 0xfd43f9148d4b725d

pub fun main(creator: Address, mid: UInt64): &DAAM.Metadata
{
    let metadataRef = getAccount(creator)
        .getCapability<&DAAM.MetadataGenerator{DAAM.MetadataGeneratorPublic}>(DAAM.metadataPublicPath)
        .borrow() ?? panic("Could not borrow capability from Metadata")

    return metadataRef.getMetadataStatus()
}
