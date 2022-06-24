// get_tokenIDs.cdc

import NonFungibleToken from 0x631e88ae7f1d7c20
<<<<<<< HEAD
import DAAM_V14 from 0xa4ad5ea5c0bd2fba

pub fun main(account: Address): [UInt64]? {
    let collectionRef = getAccount(account)
        .getCapability<&DAAM_V14.Collection{NonFungibleToken.CollectionPublic}>(DAAM_V14.collectionPublicPath)
=======
import DAAM_V15 from 0xa4ad5ea5c0bd2fba

pub fun main(account: Address): [UInt64]? {
    let collectionRef = getAccount(account)
        .getCapability<&DAAM_V15.Collection{NonFungibleToken.CollectionPublic}>(DAAM_V15.collectionPublicPath)
>>>>>>> DAAM_V15
        .borrow()
        //?? panic("Could not borrow capability from public collection")
    
    return collectionRef?.getIDs()
}
