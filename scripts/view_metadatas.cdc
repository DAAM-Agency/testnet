// view_metadatas.cdc

import DAAM_V22 from 0xa4ad5ea5c0bd2fba

pub fun main(creator: Address): [DAAM_V22.MetadataHolder] {
    let metadataRef = getAccount(creator)
        .getCapability<&DAAM_V22.MetadataGenerator{DAAM_V22.MetadataGeneratorPublic}>(DAAM_V22.metadataPublicPath)
        .borrow()!
        
    return metadataRef.viewMetadatas()
}