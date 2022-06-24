// get_collections.cdc

<<<<<<< HEAD
import DAAM_V14 from 0xa4ad5ea5c0bd2fba

pub fun main(account: Address): {String: DAAM_V14.PersonalCollection}? {
    let collectionRef = getAccount(account)
        .getCapability<&DAAM_V14.Collection{DAAM_V14.CollectionPublic}>(DAAM_V14.collectionPublicPath)
=======
import DAAM_V15 from 0xa4ad5ea5c0bd2fba

pub fun main(account: Address): {String: DAAM_V15.PersonalCollection}? {
    let collectionRef = getAccount(account)
        .getCapability<&DAAM_V15.Collection{DAAM_V15.CollectionPublic}>(DAAM_V15.collectionPublicPath)
>>>>>>> DAAM_V15
        .borrow()
        //?? panic("Could not borrow capability from public collection")
    
    return collectionRef?.getPersonalCollection()
}
