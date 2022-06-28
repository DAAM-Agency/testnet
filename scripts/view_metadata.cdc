// view_metadata.cdc

import DAAM_V17 from 0xa4ad5ea5c0bd2fba

pub fun main(creator: Address, mid: UInt64): DAAM_V17.MetadataHolder? {
    let metadataRef = getAccount(creator)
        .getCapability<&DAAM_V17.MetadataGenerator{DAAM_V17.MetadataGeneratorPublic}>(DAAM_V17.metadataPublicPath)
        .borrow()!
        
    return metadataRef.viewMetadata(mid: mid)
}