// get_mids.cdc

import DAAM_V10 from 0xa4ad5ea5c0bd2fba

pub fun main(creator: Address): [UInt64] {
    let metadataRef = getAccount(creator)
        .getCapability<&DAAM_V10.MetadataGenerator{DAAM_V10.MetadataGeneratorPublic}>(DAAM_V10.metadataPublicPath)
        .borrow()!
    
    let mids = metadataRef.getMIDs()
    return mids
}