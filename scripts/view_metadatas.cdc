// view_metadatas.cdc

import DAAM_V21 from 0xa4ad5ea5c0bd2fba

pub fun main(creator: Address): [DAAM_V21.MetadataHolder] {
    let metadataRef = getAccount(creator)
        .getCapability<&DAAM_V21.MetadataGenerator{DAAM_V21.MetadataGeneratorPublic}>(DAAM_V21.metadataPublicPath)
        .borrow()!
        
    return metadataRef.viewMetadatas()
}