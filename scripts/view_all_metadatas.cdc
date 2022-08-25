// view_all_metadatas.cdc

import DAAM_V22.V22 from 0xa4ad5ea5c0bd2fba

pub fun main(): {Address: [DAAM_V22.MetadataHolder]}
{
    let creators = DAAM_V22.V22.getCreators()
    var list: {Address: [DAAM_V22.MetadataHolder]} = {}

    for creator in creators.keys {
        let metadataRef = getAccount(creator)
        .getCapability<&DAAM_V22.MetadataGenerator{DAAM_V22.MetadataGeneratorPublic}>(DAAM_V22.metadataPublicPath)
        .borrow()!

        list.insert(key: creator, metadataRef.viewMetadatas())
    }
    return list
}