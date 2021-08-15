// collection.cdc

import DAAM from 0xf8d6e0586b0a20c7

pub fun main(account: Address): [UInt64] {
    let collectionRef = getAccount(account)
        .getCapability<&{DAAM.CollectionPublic}>(DAAM.collectionPublicPath)
        .borrow()
        ?? panic("Could not borrow capability from public collection")
    
    return collectionRef.getIDs()
}
