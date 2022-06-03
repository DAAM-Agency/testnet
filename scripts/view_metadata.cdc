// view_metadata.cdc

import DAAM_V11 from 0xa4ad5ea5c0bd2fba

pub fun main(creator: Address, mid: UInt64): DAAM_V11.MetadataHolder? {
    let metadataRef = getAccount(creator)
        .getCapability<&DAAM_V11.MetadataGenerator{DAAM_V11.MetadataGeneratorPublic}>(DAAM_V11.metadataPublicPath)
        .borrow()!
        
    return metadataRef.viewMetadata(mid: mid)
}