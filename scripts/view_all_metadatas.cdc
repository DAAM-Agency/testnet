// view_all_metadatas.cdc

import DAAM_V21 from 0xa4ad5ea5c0bd2fba

pub fun main(): {Address: [DAAM_V21.MetadataHolder]}
{
    let creators = DAAM_V21.getCreators()
    var list: {Address: [DAAM_V21.MetadataHolder]} = {}

    for creator in creators.keys {
        let metadataRef = getAccount(creator)
        .getCapability<&DAAM_V21.MetadataGenerator{DAAM_V21.MetadataGeneratorPublic}>(DAAM_V21.metadataPublicPath)
        .borrow()!

        list.insert(key: creator, metadataRef.viewMetadatas())
    }
    return list
}