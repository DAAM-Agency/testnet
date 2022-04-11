// view_metadata.cdc

import DAAM_V8 from 0xa4ad5ea5c0bd2fba

pub fun main(creator: Address, mid: UInt64): DAAM_V8.MetadataHolder? {
    let metadataRef = getAccount(creator)
        .getCapability<&DAAM_V8.MetadataGenerator{DAAM_V8.MetadataGeneratorPublic}>(DAAM_V8.metadataPublicPath)
        .borrow()!
    let metadata = metadataRef.viewMetadata(mid: mid)
    return metadata
}