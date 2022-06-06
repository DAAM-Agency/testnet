// view_all_metadatas.cdc

import DAAM from 0xfd43f9148d4b725d

pub fun main(): {Address: [DAAM.MetadataHolder]}
{
    let creators = DAAM.getCreators()
    var list: {Address: [DAAM.MetadataHolder]} = {}

    for c in creators {
        let metadataRef = getAccount(c)
        .getCapability<&DAAM.MetadataGenerator{DAAM.MetadataGeneratorPublic}>(DAAM.metadataPublicPath)
        .borrow()!

        list.insert(key: c, metadataRef.viewMetadatas())
    }
    return list
}