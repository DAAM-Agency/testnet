// get_mids.cdc

import DAAM_V19 from 0xa4ad5ea5c0bd2fba

pub fun main(creator: Address): [UInt64] {
    let metadataRef = getAccount(creator)
        .getCapability<&DAAM_V19.MetadataGenerator{DAAM_V19.MetadataGeneratorPublic}>(DAAM_V19.metadataPublicPath)
        .borrow()!
    
    let mids = metadataRef.getMIDs()
    return mids
}