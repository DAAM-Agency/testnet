// get_collections.cdc

import DAAM_V21.V21 from 0xa4ad5ea5c0bd2fba

pub fun main(account: Address): {String: DAAM_V21.V21.PersonalCollection}? {
    let collectionRef = getAccount(account)
        .getCapability<&{DAAM_V21.CollectionPublic}>(DAAM_V21.collectionPublicPath)
        .borrow()
        ?? panic("Could not borrow capability from public collection")
    
    return collectionRef.getPersonalCollection()
}
