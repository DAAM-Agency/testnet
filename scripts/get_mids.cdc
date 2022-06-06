// get_mids.cdc

import DAAM_V12 from 0xa4ad5ea5c0bd2fba

pub fun main(creator: Address): [UInt64] {
    let metadataRef = getAccount(creator)
        .getCapability<&DAAM_V12.MetadataGenerator{DAAM_V12.MetadataGeneratorPublic}>(DAAM_V12.metadataPublicPath)
        .borrow()!
    
    let mids = metadataRef.getMIDs()
    return mids
}