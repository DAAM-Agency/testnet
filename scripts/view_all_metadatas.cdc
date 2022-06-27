// view_all_metadatas.cdc

import DAAM_V16 from 0xa4ad5ea5c0bd2fba

pub fun main(): {Address: [DAAM_V16.MetadataHolder]}
{
    let creators = DAAM_V16.getCreators()
    var list: {Address: [DAAM_V16.MetadataHolder]} = {}

    for c in creators {
        let metadataRef = getAccount(c)
        .getCapability<&DAAM_V16.MetadataGenerator{DAAM_V16.MetadataGeneratorPublic}>(DAAM_V16.metadataPublicPath)
        .borrow()!

        list.insert(key: c, metadataRef.viewMetadatas())
    }
    return list
}