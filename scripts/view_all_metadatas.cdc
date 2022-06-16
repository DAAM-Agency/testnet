// view_all_metadatas.cdc

import DAAM_V13 from 0xa4ad5ea5c0bd2fba

pub fun main(): {Address: [DAAM_V13.MetadataHolder]}
{
    let creators = DAAM_V13.getCreators()
    var list: {Address: [DAAM_V13.MetadataHolder]} = {}

    for c in creators {
        let metadataRef = getAccount(c)
        .getCapability<&DAAM_V13.MetadataGenerator{DAAM_V13.MetadataGeneratorPublic}>(DAAM_V13.metadataPublicPath)
        .borrow()!

        list.insert(key: c, metadataRef.viewMetadatas())
    }
    return list
}