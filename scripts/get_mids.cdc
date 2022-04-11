// get_mids.cdc

import DAAM_V8.V8.V8_V8.. from 0xa4ad5ea5c0bd2fba

pub fun main(creator: Address): [UInt64] {
    let metadataRef = getAccount(creator)
        .getCapability<&DAAM_V8.V8..MetadataGenerator{DAAM_V8.V8..MetadataGeneratorPublic}>(DAAM_V8.V8..metadataPublicPath)
        .borrow()!
    
    let mids = metadataRef.getMIDs()
    return mids
}