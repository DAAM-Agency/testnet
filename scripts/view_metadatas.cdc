// view_metadatas.cdc

import DAAM_V11 from 0xfd43f9148d4b725d

pub fun main(creator: Address): [DAAM_V11.MetadataHolder] {
    let metadataRef = getAccount(creator)
        .getCapability<&DAAM_V11.MetadataGenerator{DAAM_V11.MetadataGeneratorPublic}>(DAAM_V11.metadataPublicPath)
        .borrow()!
        
    return metadataRef.viewMetadatas()
}