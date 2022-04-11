// get_collections.cdc

import DAAM_V8.V8.V8_V8.. from 0xa4ad5ea5c0bd2fba

pub fun main(account: Address): {String: DAAM_V8.V8..CollectionData}? {
    let collectionRef = getAccount(account)
        .getCapability<&DAAM_V8.V8..Collection{DAAM_V8.V8..CollectionPublic}>(DAAM_V8.V8..collectionPublicPath)
        .borrow()
        //?? panic("Could not borrow capability from public collection")
    
    return collectionRef?.getAlbum()
}
