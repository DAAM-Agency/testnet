// view_metadatas.cdc

import DAAM_V10 from 0xa4ad5ea5c0bd2fba

pub fun main(creator: Address): [DAAM_V10.MetadataHolder] {
    let metadataRef = getAccount(creator)
        .getCapability<&DAAM_V10.MetadataGenerator{DAAM_V10.MetadataGeneratorPublic}>(DAAM_V10.metadataPublicPath)
        .borrow()!
        
    return metadataRef.viewMetadatas()
}