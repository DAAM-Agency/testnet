// get_mids.cdc

import DAAM_V17 from 0xa4ad5ea5c0bd2fba

pub fun main(creator: Address): [UInt64] {
    let metadataRef = getAccount(creator)
        .getCapability<&DAAM_V17.MetadataGenerator{DAAM_V17.MetadataGeneratorPublic}>(DAAM_V17.metadataPublicPath)
        .borrow()!
    
    let mids = metadataRef.getMIDs()
    return mids
}