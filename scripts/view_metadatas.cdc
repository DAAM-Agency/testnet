// view_metadatas.cdc

import DAAM_Mainnet from 0xfd43f9148d4b725d

pub fun main(creator: Address): [DAAM_Mainnet.MetadataHolder] {
    let metadataRef = getAccount(creator)
        .getCapability<&DAAMDAAM_Mainnet_Mainnet.MetadataGenerator{DAAM_Mainnet.MetadataGeneratorPublic}>(DAAM_Mainnet.metadataPublicPath)
        .borrow()!
        
    return metadataRef.viewMetadatas()
}