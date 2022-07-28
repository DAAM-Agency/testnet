// view_all_metadatas.cdc

import DAAM_V19 from 0xa4ad5ea5c0bd2fba

pub fun main(): {Address: [DAAM_V19.MetadataHolder]}
{
    let creators = DAAM_V19.getCreators()
    var list: {Address: [DAAM_V19.MetadataHolder]} = {}

    for creator in creators.keys {
        let metadataRef = getAccount(creator)
        .getCapability<&DAAM_V19.MetadataGenerator{DAAM_V19.MetadataGeneratorPublic}>(DAAM_V19.metadataPublicPath)
        .borrow()!

        list.insert(key: creator, metadataRef.viewMetadatas())
    }
    return list
}