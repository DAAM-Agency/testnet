// get_collections.cdc

import DAAM_V10 from 0xa4ad5ea5c0bd2fba

pub fun main(account: Address): {String: DAAM_V10.CollectionData}? {
    let collectionRef = getAccount(account)
        .getCapability<&DAAM_V10.Collection{DAAM_V10.CollectionPublic}>(DAAM_V10.collectionPublicPath)
        .borrow()
        //?? panic("Could not borrow capability from public collection")
    
    return collectionRef?.getAlbum()
}
