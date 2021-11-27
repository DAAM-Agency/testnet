// collection.cdc

import DAAM from 0xfd43f9148d4b725d

pub fun main(account: Address): [UInt64]? {
    let collectionRef = getAccount(account)
        .getCapability<&{DAAM.CollectionPublic}>(DAAM.collectionPublicPath)
        .borrow()
        //?? panic("Could not borrow capability from public collection")
    
    return collectionRef?.getIDs()
}