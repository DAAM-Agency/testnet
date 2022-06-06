// view_metadatas.cdc

import DAAM from 0xfd43f9148d4b725d

pub fun main(creator: Address): [DAAM.MetadataHolder] {
    let metadataRef = getAccount(creator)
        .getCapability<&DAAM.MetadataGenerator{DAAM.MetadataGeneratorPublic}>(DAAM.metadataPublicPath)
        .borrow()!
        
    return metadataRef.viewMetadatas()
}