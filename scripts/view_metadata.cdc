// view_metadata.cdc

import DAAM from 0xa4ad5ea5c0bd2fba

pub fun main(creator: Address, mid: UInt64): DAAM.MetadataHolder? {
    let metadataRef = getAccount(creator)
        .getCapability<&DAAM.MetadataGenerator{DAAM.MetadataGeneratorPublic}>(DAAM.metadataPublicPath)
        .borrow()!
        
    return metadataRef.viewMetadata(mid: mid)
}