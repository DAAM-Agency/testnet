// get_tokenIDs.cdc

import NonFungibleToken from 0xf8d6e0586b0a20c7
import DAAM from 0xfd43f9148d4b725d

pub fun main(account: Address): [UInt64]? {
    let collectionRef = getAccount(account)
        .getCapability<&{NonFungibleToken.CollectionPublic}>(DAAM.collectionPublicPath)
        .borrow()
        ?? panic("Could not borrow capability from public collection")
    
    return collectionRef.getIDs()
}
