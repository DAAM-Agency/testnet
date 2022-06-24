// view_metadatas.cdc

import DAAM_V15 from 0xa4ad5ea5c0bd2fba

pub fun main(creator: Address): [DAAM_V15.MetadataHolder] {
    let metadataRef = getAccount(creator)
        .getCapability<&DAAM_V15.MetadataGenerator{DAAM_V15.MetadataGeneratorPublic}>(DAAM_V15.metadataPublicPath)
        .borrow()!
        
    return metadataRef.viewMetadatas()
}