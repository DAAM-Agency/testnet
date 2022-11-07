// view_metadatas.cdc

import DAAM_Mainnet from 0xa4ad5ea5c0bd2fba

pub fun main(creator: Address): [DAAM_Mainnet.MetadataHolder] {
    let metadataRef = getAccount(creator)
        .getCapability<&DAAMDAAM_Mainnet_Mainnet.MetadataGenerator{DAAM_Mainnet.MetadataGeneratorPublic}>(DAAM_Mainnet.metadataPublicPath)
        .borrow()!
        
    return metadataRef.viewMetadatas()
}