// get_mids.cdc

import DAAM_Mainnet from 0xfd43f9148d4b725d

pub fun main(creator: Address): [UInt64] {
    let metadataRef = getAccount(creator)
        .getCapability<&DAAMDAAM_Mainnet_Mainnet.MetadataGenerator{DAAM_Mainnet.MetadataGeneratorPublic}>(DAAM_Mainnet.metadataPublicPath)
        .borrow()!
    
    let mids = metadataRef.getMIDs()
    return mids
}