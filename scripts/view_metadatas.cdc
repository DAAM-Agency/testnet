// view_metadatas.cdc

import DAAM from 0x7db4d10c78bad30a

pub fun main(creator: Address): [DAAM.MetadataHolder] {
    let metadataRef = getAccount(creator)
        .getCapability<&DAAM.MetadataGenerator{DAAM.MetadataGeneratorPublic}>(DAAM.metadataPublicPath)
        .borrow()!
        
    return metadataRef.viewMetadatas()
}