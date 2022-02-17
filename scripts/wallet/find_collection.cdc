// get_collections.cdc

import DAAM from 0xfd43f9148d4b725d

pub fun main(account: Address, tokenID: UInt64): [String]? {
    let collectionRef = getAccount(account)
        .getCapability<&DAAM.Collection{DAAM.CollectionPublic}>(DAAM.collectionPublicPath)
        .borrow()
        //?? panic("Could not borrow capability from public collection")
    
    return collectionRef?.findCollection(tokenID: tokenID)
}