// view_metadatas.cdc

import DAAM_V13 from 0xa4ad5ea5c0bd2fba

pub fun main(creator: Address): [DAAM_V13.MetadataHolder] {
    let metadataRef = getAccount(creator)
        .getCapability<&DAAM_V13.MetadataGenerator{DAAM_V13.MetadataGeneratorPublic}>(DAAM_V13.metadataPublicPath)
        .borrow()!
        
    return metadataRef.viewMetadatas()
}