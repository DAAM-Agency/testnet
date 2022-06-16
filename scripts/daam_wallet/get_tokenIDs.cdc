// get_tokenIDs.cdc

import NonFungibleToken from 0x631e88ae7f1d7c20
import DAAM from 0xa4ad5ea5c0bd2fba

pub fun main(account: Address): [UInt64]? {
    let collectionRef = getAccount(account)
        .getCapability<&DAAM.Collection{NonFungibleToken.CollectionPublic}>(DAAM.collectionPublicPath)
        .borrow()
        //?? panic("Could not borrow capability from public collection")
    
    return collectionRef?.getIDs()
}
