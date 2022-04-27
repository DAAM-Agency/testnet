// view_metadata.cdc

import DAAM_V9 from 0xa4ad5ea5c0bd2fba

pub fun main(creator: Address, mid: UInt64): DAAM_V9.MetadataHolder? {
    let metadataRef = getAccount(creator)
        .getCapability<&DAAM_V9.MetadataGenerator{DAAM_V9.MetadataGeneratorPublic}>(DAAM_V9.metadataPublicPath)
        .borrow()!
        
    return metadataRef.viewMetadata(mid: mid)
}