// view_metadatas.cdc

import DAAM_V19 from 0xa4ad5ea5c0bd2fba

pub fun main(creator: Address): [DAAM_V19.MetadataHolder] {
    let metadataRef = getAccount(creator)
        .getCapability<&DAAM_V19.MetadataGenerator{DAAM_V19.MetadataGeneratorPublic}>(DAAM_V19.metadataPublicPath)
        .borrow()!
        
    return metadataRef.viewMetadatas()
}