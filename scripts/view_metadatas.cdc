// view_metadatas.cdc

import DAAM_V16 from 0xa4ad5ea5c0bd2fba

pub fun main(creator: Address): [DAAM_V16.MetadataHolder] {
    let metadataRef = getAccount(creator)
        .getCapability<&DAAM_V16.MetadataGenerator{DAAM_V16.MetadataGeneratorPublic}>(DAAM_V16.metadataPublicPath)
        .borrow()!
        
    return metadataRef.viewMetadatas()
}