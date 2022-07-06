// view_all_metadatas.cdc

import DAAM_V18 from 0xa4ad5ea5c0bd2fba

pub fun main(): {Address: [DAAM_V18.MetadataHolder]}
{
    let creators = DAAM_V18.getCreators()
    var list: {Address: [DAAM_V18.MetadataHolder]} = {}

    for creator in creators.keys {
        let metadataRef = getAccount(creator)
        .getCapability<&DAAM_V18.MetadataGenerator{DAAM_V18.MetadataGeneratorPublic}>(DAAM_V18.metadataPublicPath)
        .borrow()!

        list.insert(key: creator, metadataRef.viewMetadatas())
    }
    return list
}