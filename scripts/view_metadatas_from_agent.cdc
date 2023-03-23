// view_metadatas_from_agent.cdc

import DAAM from 0x7db4d10c78bad30a

pub fun main(agent: Address): {Address : [DAAM.MetadataHolder]} {
    let creators = DAAM.getAgentCreators(agent: agent)!
    var list: {Address : [DAAM.MetadataHolder] } = {}

    for creator in creators {
        let metadataRef = getAccount(creator)
        .getCapability<&DAAM.MetadataGenerator{DAAM.MetadataGeneratorPublic}>(DAAM.metadataPublicPath)
        .borrow()!
        
        list.insert(key: creator, metadataRef.viewMetadatas())
    }
    return list
}
