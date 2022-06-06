// get_collections.cdc

import DAAM from 0xa4ad5ea5c0bd2fba

pub fun main(account: Address): {String: DAAM.PersonalCollection}? {
    let collectionRef = getAccount(account)
        .getCapability<&DAAM.Collection{DAAM.CollectionPublic}>(DAAM.collectionPublicPath)
        .borrow()
        //?? panic("Could not borrow capability from public collection")
    
    return collectionRef?.getPersonalCollection()
}
