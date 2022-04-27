// get_mids.cdc

import DAAM_V9 from 0xa4ad5ea5c0bd2fba

pub fun main(creator: Address): [UInt64] {
    let metadataRef = getAccount(creator)
        .getCapability<&DAAM_V9.MetadataGenerator{DAAM_V9.MetadataGeneratorPublic}>(DAAM_V9.metadataPublicPath)
        .borrow()!
    
    let mids = metadataRef.getMIDs()
    return mids
}