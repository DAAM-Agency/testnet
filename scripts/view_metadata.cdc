// view_metadata.cdc

import DAAM_V20 from 0xa4ad5ea5c0bd2fba

pub fun main(creator: Address, mid: UInt64): DAAM_V20.MetadataHolder? {
    let metadataRef = getAccount(creator)
        .getCapability<&DAAM_V20.MetadataGenerator{DAAM_V20.MetadataGeneratorPublic}>(DAAM_V20.metadataPublicPath)
        .borrow()!
        
    return metadataRef.viewMetadata(mid: mid)
}