// get_mids.cdc

import DAAM_V15 from 0xa4ad5ea5c0bd2fba

pub fun main(creator: Address): [UInt64] {
    let metadataRef = getAccount(creator)
        .getCapability<&DAAM_V15.MetadataGenerator{DAAM_V15.MetadataGeneratorPublic}>(DAAM_V15.metadataPublicPath)
        .borrow()!
    
    let mids = metadataRef.getMIDs()
    return mids
}