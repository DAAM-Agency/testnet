// view_all_metadatas.cdc

import DAAM_V17 from 0xa4ad5ea5c0bd2fba

pub fun main(): {Address: [DAAM_V17.MetadataHolder]}
{
    let creators = DAAM_V17.getCreators()
    var list: {Address: [DAAM_V17.MetadataHolder]} = {}

    for c in creators {
        let metadataRef = getAccount(c)
        .getCapability<&DAAM_V17.MetadataGenerator{DAAM_V17.MetadataGeneratorPublic}>(DAAM_V17.metadataPublicPath)
        .borrow()!

        list.insert(key: c, metadataRef.viewMetadatas())
    }
    return list
}