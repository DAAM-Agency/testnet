// view_metadatas.cdc

import DAAM_V22 from 0xa4ad5ea5c0bd2fba

pub fun main(creator: Address): [DAAM.MetadataHolder] {
    let metadataRef = getAccount(creator)
        .getCapability<&DAAM.MetadataGenerator{DAAM.MetadataGeneratorPublic}>(DAAM.metadataPublicPath)
        .borrow()!
        
    return metadataRef.viewMetadatas()
}