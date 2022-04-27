// get_collections.cdc

import DAAM_V9 from 0xa4ad5ea5c0bd2fba

pub fun main(account: Address, tokenID: UInt64): [String]? {
    let collectionRef = getAccount(account)
        .getCapability<&DAAM_V9.Collection{DAAM_V9.CollectionPublic}>(DAAM_V9.collectionPublicPath)
        .borrow()
        //?? panic("Could not borrow capability from public collection")
    
    return collectionRef?.findCollection(tokenID: tokenID)
}
