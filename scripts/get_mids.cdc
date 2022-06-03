// get_mids.cdc

import DAAM_V11 from 0xfd43f9148d4b725d

pub fun main(creator: Address): [UInt64] {
    let metadataRef = getAccount(creator)
        .getCapability<&DAAM_V11.MetadataGenerator{DAAM_V11.MetadataGeneratorPublic}>(DAAM_V11.metadataPublicPath)
        .borrow()!
    
    let mids = metadataRef.getMIDs()
    return mids
}