// view_all_metadatas.cdc

import DAAM_V9 from 0xa4ad5ea5c0bd2fba

pub fun main(): {Address: [DAAM_V9.MetadataHolder]}
{
    let creators = DAAM_V9.getCreators()
    var list: {Address: [DAAM_V9.MetadataHolder]} = {}

    for c in creators {
        let metadataRef = getAccount(c)
        .getCapability<&DAAM_V9.MetadataGenerator{DAAM_V9.MetadataGeneratorPublic}>(DAAM_V9.metadataPublicPath)
        .borrow()!

        list.insert(key: c, metadataRef.viewMetadatas())
    }
    return list
}