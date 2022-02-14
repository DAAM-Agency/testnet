// get_collections.cdc

import DAAM from 0xfd43f9148d4b725d

pub fun main(account: Address): [String]? {
    let collectionRef = getAccount(account)
        .getCapability<&DAAM.Collection{DAAM.CollectionName}>(DAAM.collectionPublicPath)
        .borrow()
        ?? panic("Could not borrow capability from public collection")
    
    return collectionRef?.getCollections()
}
