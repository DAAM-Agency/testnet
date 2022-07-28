// view_all_metadatas.cdc

import DAAM_V20 from 0xa4ad5ea5c0bd2fba

pub fun main(): {Address: [DAAM_V20.MetadataHolder]}
{
    let creators = DAAM_V20.getCreators()
    var list: {Address: [DAAM_V20.MetadataHolder]} = {}

    for creator in creators.keys {
        let metadataRef = getAccount(creator)
        .getCapability<&DAAM_V20.MetadataGenerator{DAAM_V20.MetadataGeneratorPublic}>(DAAM_V20.metadataPublicPath)
        .borrow()!

        list.insert(key: creator, metadataRef.viewMetadatas())
    }
    return list
}