// view_metadata.cdc

import DAAM_V23 from 0xa4ad5ea5c0bd2fba

pub fun main(creator: Address, mid: UInt64): DAAM_V23.MetadataHolder? {
    let metadataRef = getAccount(creator)
        .getCapability<&DAAM.MetadataGenerator{DAAM.MetadataGeneratorPublic}>(DAAM.metadataPublicPath)
        .borrow()!
        
    return metadataRef.viewMetadata(mid: mid)
}