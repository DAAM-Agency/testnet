// view_all_metadatas.cdc

import DAAM_Mainnet from 0xfd43f9148d4b725d

pub fun main(): {Address: [DAAM_Mainnet.MetadataHolder]}
{
    let creators = DAAM_Mainnet.getCreators()
    var list: {Address: [DAAM_Mainnet.MetadataHolder]} = {}

    for creator in creators.keys {
        let metadataRef = getAccount(creator)
        .getCapability<&DAAMDAAM_Mainnet_Mainnet.MetadataGenerator{DAAM_Mainnet.MetadataGeneratorPublic}>(DAAM_Mainnet.metadataPublicPath)
        .borrow()!

        list.insert(key: creator, metadataRef.viewMetadatas())
    }
    return list
}