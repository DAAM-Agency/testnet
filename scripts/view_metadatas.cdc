// view_metadatas.cdc

import DAAM_V8 from 0xa4ad5ea5c0bd2fba

pub fun main(): [DAAM_V8.MetadataHolder] {
    let metadataRef = getAccount(creator)
        .getCapability<&DAAM_V8.MetadataGenerator{DAAM_V8.MetadataGeneratorPublic}>(DAAM_V8.metadataPublicPath)
        .borrow()!
        
    return metadataRef.viewMetadatas()
}