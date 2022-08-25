// view_all_metadatas.cdc

import DAAM from 0xa4ad5ea5c0bd2fba

pub fun main(): {Address: [DAAM.MetadataHolder]}
{
    let creators = DAAM.getCreators()
    var list: {Address: [DAAM.MetadataHolder]} = {}

    for creator in creators.keys {
        let metadataRef = getAccount(creator)
        .getCapability<&DAAM.MetadataGenerator{DAAM.MetadataGeneratorPublic}>(DAAM.metadataPublicPath)
        .borrow()!

        list.insert(key: creator, metadataRef.viewMetadatas())
    }
    return list
}