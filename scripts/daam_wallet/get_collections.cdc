// get_collections.cdc

import DAAM_V16 from 0xa4ad5ea5c0bd2fba

pub fun main(account: Address): {String: DAAM_V16.PersonalCollection}? {
    let collectionRef = getAccount(account)
        .getCapability<&DAAM_V16.Collection{DAAM_V16.CollectionPublic}>(DAAM_V16.collectionPublicPath)
        .borrow()
        //?? panic("Could not borrow capability from public collection")
    
    return collectionRef?.getPersonalCollection()
}
