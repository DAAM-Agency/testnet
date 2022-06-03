// view_all_metadatas.cdc

import DAAM_V11 from 0xa4ad5ea5c0bd2fba

pub fun main(): {Address: [DAAM_V11.MetadataHolder]}
{
    let creators = DAAM_V11.getCreators()
    var list: {Address: [DAAM_V11.MetadataHolder]} = {}

    for c in creators {
        let metadataRef = getAccount(c)
        .getCapability<&DAAM_V11.MetadataGenerator{DAAM_V11.MetadataGeneratorPublic}>(DAAM_V11.metadataPublicPath)
        .borrow()!

        list.insert(key: c, metadataRef.viewMetadatas())
    }
    return list
}