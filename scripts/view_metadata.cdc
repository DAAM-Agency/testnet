// view_metadata.cdc

import DAAM from 0xfd43f9148d4b725d

pub fun main(creator: Address, mid: UInt64): DAAM.MetadataHolder? {
    let metadataRef = getAccount(creator)
        .getCapability<&DAAM.MetadataGenerator{DAAM.MetadataGeneratorPublic}>(DAAM.metadataPublicPath)
        .borrow()!
    let metadata = metadataRef.viewMetadata(mid: mid)
    return metadata
}