// get_collections.cdc

import DAAM_V11 from 0xa4ad5ea5c0bd2fba

pub fun main(account: Address): {String: DAAM_V11.PersonalCollection}? {
    let collectionRef = getAccount(account)
        .getCapability<&DAAM_V11.Collection{DAAM_V11.CollectionPublic}>(DAAM_V11.collectionPublicPath)
        .borrow()
        //?? panic("Could not borrow capability from public collection")
    
    return collectionRef?.getPersonalCollection()
}
