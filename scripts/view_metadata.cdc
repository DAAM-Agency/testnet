// view_metadata.cdc

import DAAM from 0x7db4d10c78bad30a

pub fun main(creator: Address, mid: UInt64): DAAM.MetadataHolder? {
    let metadataRef = getAccount(creator)
        .getCapability<&DAAM.MetadataGenerator{DAAM.MetadataGeneratorPublic}>(DAAM.metadataPublicPath)
        .borrow()!
        
    return metadataRef.viewMetadata(mid: mid)
}