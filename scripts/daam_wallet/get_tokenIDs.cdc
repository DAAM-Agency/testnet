// get_tokenIDs.cdc

<<<<<<< HEAD
import DAAM_V10 from 0xa4ad5ea5c0bd2fba

pub fun main(account: Address): [UInt64]? {
    let collectionRef = getAccount(account)
        .getCapability<&DAAM_V10.Collection{DAAM_V10.CollectionPublic}>(DAAM_V10.collectionPublicPath)
=======
import NonFungibleToken from 0x631e88ae7f1d7c20
import DAAM_V14 from 0xa4ad5ea5c0bd2fba

pub fun main(account: Address): [UInt64]? {
    let collectionRef = getAccount(account)
        .getCapability<&DAAM_V14.Collection{NonFungibleToken.CollectionPublic}>(DAAM_V14.collectionPublicPath)
>>>>>>> DAAM_V14
        .borrow()
        //?? panic("Could not borrow capability from public collection")
    
    return collectionRef?.getIDs()
}
