// get_collections.cdc

import DAAM_V18 from 0xa4ad5ea5c0bd2fba

pub fun main(account: Address): {String: DAAM_V18.PersonalCollection}? {
    let collectionRef = getAccount(account)
        .getCapability<&DAAM_V18.Collection{DAAM_V18.CollectionPublic}>(DAAM_V18.collectionPublicPath)
        .borrow()
        //?? panic("Could not borrow capability from public collection")
    
    return collectionRef?.getPersonalCollection()
}
