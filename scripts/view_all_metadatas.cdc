// view_all_metadatas.cdc

import DAAM_V14 from 0xa4ad5ea5c0bd2fba

pub fun main(): {Address: [DAAM_V14.MetadataHolder]}
{
    let creators = DAAM_V14.getCreators()
    var list: {Address: [DAAM_V14.MetadataHolder]} = {}

    for c in creators {
        let metadataRef = getAccount(c)
        .getCapability<&DAAM_V14.MetadataGenerator{DAAM_V14.MetadataGeneratorPublic}>(DAAM_V14.metadataPublicPath)
        .borrow()!

        list.insert(key: c, metadataRef.viewMetadatas())
    }
    return list
}