// view_all_metadatas.cdc

import DAAM_V8 from 0xa4ad5ea5c0bd2fba

pub fun main(): {Address: [DAAM_V8.MetadataHolder]}
{
    let creators = DAAM_V8.getCreators()
    var list: {Address: [DAAM_V8.MetadataHolder]} = {}

    for c in creators {
        let metadataRef = getAccount(c)
        .getCapability<&DAAM_V8.MetadataGenerator{DAAM_V8.MetadataGeneratorPublic}>(DAAM_V8.metadataPublicPath)
        .borrow()!

        list.insert(key: c, metadataRef.viewMetadatas())
    }
    return list
}