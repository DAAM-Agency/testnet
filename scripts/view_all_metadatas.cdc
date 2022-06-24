// view_all_metadatas.cdc

import DAAM_V15 from 0xa4ad5ea5c0bd2fba

pub fun main(): {Address: [DAAM_V15.MetadataHolder]}
{
    let creators = DAAM_V15.getCreators()
    var list: {Address: [DAAM_V15.MetadataHolder]} = {}

    for c in creators {
        let metadataRef = getAccount(c)
        .getCapability<&DAAM_V15.MetadataGenerator{DAAM_V15.MetadataGeneratorPublic}>(DAAM_V15.metadataPublicPath)
        .borrow()!

        list.insert(key: c, metadataRef.viewMetadatas())
    }
    return list
}