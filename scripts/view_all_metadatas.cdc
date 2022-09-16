// view_all_metadatas.cdc

import DAAM_V23 from 0xa4ad5ea5c0bd2fba

pub fun main(): {Address: [DAAM_V23.MetadataHolder]}
{
    let creators = DAAM_V23.getCreators()
    var list: {Address: [DAAM_V23.MetadataHolder]} = {}

    for creator in creators.keys {
        let metadataRef = getAccount(creator)
        .getCapability<&DAAM_V23.MetadataGenerator{DAAM_V23.MetadataGeneratorPublic}>(DAAM_V23.metadataPublicPath)
        .borrow()!

        list.insert(key: creator, metadataRef.viewMetadatas())
    }
    return list
}