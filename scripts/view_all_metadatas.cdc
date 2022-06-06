// view_all_metadatas.cdc

import DAAM_V12 from 0xa4ad5ea5c0bd2fba

pub fun main(): {Address: [DAAM_V12.MetadataHolder]}
{
    let creators = DAAM_V12.getCreators()
    var list: {Address: [DAAM_V12.MetadataHolder]} = {}

    for c in creators {
        let metadataRef = getAccount(c)
        .getCapability<&DAAM_V12.MetadataGenerator{DAAM_V12.MetadataGeneratorPublic}>(DAAM_V12.metadataPublicPath)
        .borrow()!

        list.insert(key: c, metadataRef.viewMetadatas())
    }
    return list
}