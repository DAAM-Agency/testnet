// view_metadata.cdc

import DAAM_V14 from 0xa4ad5ea5c0bd2fba

pub fun main(creator: Address, mid: UInt64): DAAM_V14.MetadataHolder? {
    let metadataRef = getAccount(creator)
        .getCapability<&DAAM_V14.MetadataGenerator{DAAM_V14.MetadataGeneratorPublic}>(DAAM_V14.metadataPublicPath)
        .borrow()!
        
    return metadataRef.viewMetadata(mid: mid)
}