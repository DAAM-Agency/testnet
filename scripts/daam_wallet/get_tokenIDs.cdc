// get_tokenIDs.cdc

import NonFungibleToken from 0x631e88ae7f1d7c20
import DAAM_V11 from 0xa4ad5ea5c0bd2fba

pub fun main(account: Address): [UInt64]? {
    let collectionRef = getAccount(account)
        .getCapability<&DAAM_V11.Collection{NonFungibleToken.CollectionPublic}>(DAAM_V11.collectionPublicPath)
        .borrow()
        //?? panic("Could not borrow capability from public collection")
    
    return collectionRef?.getIDs()
}
