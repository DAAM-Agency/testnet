// collection.cdc

import DAAM_V1 from 0xa4ad5ea5c0bd2fba

pub fun main(account: Address): [UInt64] {
    let collectionRef = getAccount(account)
        .getCapability<&{DAAM_V1.CollectionPublic}>(DAAM_V1.collectionPublicPath)
        .borrow()
        ?? panic("Could not borrow capability from public collection")
    
    return collectionRef.getIDs()
}
