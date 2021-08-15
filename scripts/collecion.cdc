// collection.cdc

import DAAM_V3.V2 from 0xa4ad5ea5c0bd2fba

pub fun main(account: Address): [UInt64] {
    let collectionRef = getAccount(account)
        .getCapability<&{DAAM_V3.CollectionPublic}>(DAAM_V3.collectionPublicPath)
        .borrow()
        ?? panic("Could not borrow capability from public collection")
    
    return collectionRef.getIDs()
}
